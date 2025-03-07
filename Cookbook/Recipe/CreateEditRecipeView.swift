//
//  AddRecipeView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI

struct CreateEditRecipeView: View {
    
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataController: DataController
    
    @Bindable var recipe: Recipe
    
    @State var ingredientToEdit: Ingredient?
    var isNewRecipe: Bool
    
    @State private var alertShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            form
                .toolbar {
                    if (isNewRecipe) {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Label("Back", systemImage: "chevron.backward").labelStyle(.titleAndIcon)
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if (recipe.name.isEmpty) {
                                alertShowing = true
                                return
                            }
                            context.insert(recipe)
                            try! context.save()
                            
                            dismiss()
                        } label: {
                            Label("Done", systemImage: "return")
                                .labelStyle(.titleOnly)
                        }
                    }
                }
                .sheet(item: $ingredientToEdit, content: { ingredient in
                    CreateEditIngredientModal(ingredients: recipe.ingredients!, ingredient: ingredient) {newIngredient in
                        recipe.ingredients!.append(newIngredient)
                        ingredientToEdit = nil
                    }
                })
                .alert("Recipes must have a name.", isPresented: $alertShowing, actions: {})
                .navigationTitle(isNewRecipe ? "New Recipe" : "Edit \"\(recipe.name)\"")
                .scrollDismissesKeyboard(.immediately)
        }
    }
    
    
    var form: some View {
        Form {
            
            Section {
                let linkBinding = Binding<String>(get: {
                    recipe.link ?? ""
                }, set: {
                    recipe.link = $0
                })
                
                TextField("", text: linkBinding)
                    .submitLabel(.done)
                    .onSubmit {
                        Task {
                            guard let link = recipe.link else {return}
                            
                            if let url = URL(string: link) {
                                let scraper = Scraper(url: url)
                                
                                guard let recipeData = await scraper.getRecipeData() else {return}
                                
                                if let name = recipeData.name {
                                    recipe.name = name
                                }
                                
                                if let instructions = recipeData.instructions {
                                    recipe.instructions = instructions
                                }
                                
                                if let imageUrl = recipeData.imageUrls?.first {
                                    recipe.imageUrl = URL(string: imageUrl)
                                }
                                
                                if let ingredients = recipeData.ingredients {
                                    recipe.ingredients = ingredients
                                }
                            }
                        }
                    }
            } header: {
                Text("Link")
            }  footer: {
                Text("Cookbook will pull recipe data from the link provided")
            }
            Section {
                TextField("", text: $recipe.name)
            } header: {
                Text("Name")
            }
            
            Section {
                TextField("", text: $recipe.instructions, axis: .vertical)
                    .lineLimit(5...)
            } header: {
                Text("Instructions")
            }
            
            ListButton(text: "Add Ingredients", imageSystemName: "plus") {
                ingredientToEdit = Ingredient(name: "", quantityWhole: 1, quantityFraction: 0, unit: .item, index: recipe.getNextIngredientIndex())
            }
            
            if (!recipe.ingredients!.isEmpty) {
                Section {
                    List {
                        ForEach(recipe.ingredients!.sorted {$0.index < $1.index}) {ingredient in
                            IngredientCell(ingredient: ingredient)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        recipe.ingredients!.removeAll(where: {$0.id == ingredient.id})
                                        
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                            .labelStyle(.iconOnly)
                                    }
                                    .tint(.red)
                                    
                                    Button {
                                        ingredientToEdit = ingredient
                                    } label: {
                                        Label("Edit", systemImage: "square.and.pencil")
                                            .labelStyle(.iconOnly)
                                    }
                                    .tint(.yellow)
                                }
                        }
                    }
                    
                } header: {Text("Ingredients")}
            }
        }
    }
}
