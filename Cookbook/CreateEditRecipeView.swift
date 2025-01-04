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
    
    @Bindable var recipe: Recipe
    
    @State var ingredientIdToEdit: UUID?
    var isNewRecipe: Bool
    
    @State private var ingredientModalShowing: Bool = false
    @State private var alertShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("", text: $recipe.name)
                } header: {
                    Text("Name")
                }
                
                Section {
                    TextField("", text: $recipe.instructions, axis: .vertical)
                        .lineLimit(5...10)
                } header: {
                    Text("Instructions")
                }
                
                Button("+ Add Ingredients") {
                    ingredientIdToEdit = nil
                    ingredientModalShowing = true
                }
                
                if (!recipe.ingredients.isEmpty) {
                    Section {
                        List {
                            ForEach(recipe.ingredients) {ingredient in
                                IngredientCell(ingredient: ingredient)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            recipe.ingredients.removeAll(where: {$0.id == ingredient.id})
                                            
                                        } label: {
                                            Text("Delete")
                                        }
                                        .tint(.red)
                                        
                                        Button {
                                            ingredientIdToEdit = ingredient.id
                                            ingredientModalShowing = true
                                        } label: {
                                            Text("Edit")
                                        }
                                        .tint(.yellow)
                                    }
                            }
                        }
                        
                    } header: {Text("Ingredients")}
                }
            }.toolbar {
                if (isNewRecipe) {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "chevron.backward")
                                Text("Back")
                            }
                            
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if (recipe.name.isEmpty) {
                            alertShowing = true
                            return
                        }
                        recipe.createUpdateRecipe(context: context)
                        dismiss()
                    } label: {
                        
                        Text("Done")
                    }
                }
                
            }
            .sheet(isPresented: $ingredientModalShowing) {
                if let id = ingredientIdToEdit {
                    @Bindable var ingredient = recipe.ingredients.filter({ $0.id == id}).first!
                    CreateEditIngredientModal(ingredients: $recipe.ingredients, ingredient: ingredient)
                } else {
                    @Bindable var ingredient = Ingredient(name: "", recipe: recipe, quantityWhole: 1, quantityFraction: 0, unit: "item")
                    CreateEditIngredientModal(ingredients: $recipe.ingredients, ingredient: ingredient)
                }
            }
            .alert("Recipes must have a name.", isPresented: $alertShowing, actions: {})
            .navigationTitle(isNewRecipe ? "New Recipe" : "Edit \"\(recipe.name)\"")
            .scrollDismissesKeyboard(.immediately)
        }
    }
}
