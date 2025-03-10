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
    
    @State private var linkFormShowing: Bool = true
    @State private var alertShowing: Bool = false
    
    func fetchRecipeData() async {
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
                .overlay(content: {
                    PrettyAlert(isShowing: $alertShowing, text: "Recipes must have a name.", icon: "character.textbox")
                })
                .navigationTitle(isNewRecipe ? "New Recipe" : "Edit \"\(recipe.name)\"")
                .scrollDismissesKeyboard(.immediately)
        }
    }
    
    
    var form: some View {
        
        VStack {
            
            HStack {
                Button {
                    linkFormShowing = true
                } label: {
                    Label("From link", systemImage: "link")
                }
                .padding()
                .foregroundStyle(.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.accent, lineWidth: linkFormShowing ? 2 : 0)
                    )
                
                Button {
                    linkFormShowing = false
                } label: {
                    Label("Manual", systemImage: "list.bullet")
                }
                .padding()
                .foregroundStyle(.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.accent, lineWidth: !linkFormShowing ? 2 : 0)
                    )
            }
            
            if (linkFormShowing == true) {
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
                                    await fetchRecipeData()
                                    linkFormShowing = false
                                }
                            }
                    } header: {
                        Text("Link")
                    }  footer: {
                        Text("Cookbook will pull recipe data from the link provided")
                    }
                    
                    ListButton(text: "Search", imageSystemName: "text.page.badge.magnifyingglass", disabled: recipe.link?.isEmpty == nil) {
                        Task {
                            await fetchRecipeData()
                            linkFormShowing = false
                        }
                    }
                }
            } else {
                Form {
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
                    
                    ListButton(text: "Add Ingredients", imageSystemName: "plus", disabled: false) {
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
        
//        
//        
//        Form {
//            Section {
//                let linkBinding = Binding<String>(get: {
//                    recipe.link ?? ""
//                }, set: {
//                    recipe.link = $0
//                })
//                
//                TextField("", text: linkBinding)
//                    .submitLabel(.done)
//                    .onSubmit {
//                        Task {
//                            guard let link = recipe.link else {return}
//                            
//                            if let url = URL(string: link) {
//                                let scraper = Scraper(url: url)
//                                
//                                guard let recipeData = await scraper.getRecipeData() else {return}
//                                
//                                if let name = recipeData.name {
//                                    recipe.name = name
//                                }
//                                
//                                if let instructions = recipeData.instructions {
//                                    recipe.instructions = instructions
//                                }
//                                
//                                if let imageUrl = recipeData.imageUrls?.first {
//                                    recipe.imageUrl = URL(string: imageUrl)
//                                }
//                                
//                                if let ingredients = recipeData.ingredients {
//                                    recipe.ingredients = ingredients
//                                }
//                            }
//                        }
//                    }
//            } header: {
//                Text("Link")
//            }  footer: {
//                Text("Cookbook will pull recipe data from the link provided")
//            }
//            Section {
//                TextField("", text: $recipe.name)
//            } header: {
//                Text("Name")
//            }
//            
//            Section {
//                TextField("", text: $recipe.instructions, axis: .vertical)
//                    .lineLimit(5...)
//            } header: {
//                Text("Instructions")
//            }
//            
//            ListButton(text: "Add Ingredients", imageSystemName: "plus") {
//                ingredientToEdit = Ingredient(name: "", quantityWhole: 1, quantityFraction: 0, unit: .item, index: recipe.getNextIngredientIndex())
//            }
//            
//            if (!recipe.ingredients!.isEmpty) {
//                Section {
//                    List {
//                        ForEach(recipe.ingredients!.sorted {$0.index < $1.index}) {ingredient in
//                            IngredientCell(ingredient: ingredient)
//                                .swipeActions {
//                                    Button(role: .destructive) {
//                                        recipe.ingredients!.removeAll(where: {$0.id == ingredient.id})
//                                        
//                                    } label: {
//                                        Label("Delete", systemImage: "trash")
//                                            .labelStyle(.iconOnly)
//                                    }
//                                    .tint(.red)
//                                    
//                                    Button {
//                                        ingredientToEdit = ingredient
//                                    } label: {
//                                        Label("Edit", systemImage: "square.and.pencil")
//                                            .labelStyle(.iconOnly)
//                                    }
//                                    .tint(.yellow)
//                                }
//                        }
//                    }
//                    
//                } header: {Text("Ingredients")}
//            }
//        }
    }
}
