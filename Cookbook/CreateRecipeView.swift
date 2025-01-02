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
    
    @State private var ingredientModalShowing: Bool = false
    
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
                    ingredientModalShowing = true
                }
                
                if (!recipe.ingredients.isEmpty) {
                    Section {
                        List {
                            ForEach(recipe.ingredients) {ingredient in
                                IngredientCell(ingredient: ingredient)
                            }.onDelete { indexSet in
                                recipe.ingredients.remove(atOffsets: indexSet)
                            }
                        }
                        
                    } header: {Text("Ingredients")}
                }
            }.toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        recipe.createUpdateRecipe(context: context)
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
            .sheet(isPresented: $ingredientModalShowing) {
                @Bindable var ingredient = Ingredient(name: "", recipe: recipe, quantityWhole: 1, quantityFractionString: "", unit: "item")
                CreateEditIngredientModal(ingredients: $recipe.ingredients, ingredient: ingredient)
            }
            .navigationTitle(recipe.name.isEmpty ? "New Recipe" : recipe.name)
            .scrollDismissesKeyboard(.immediately)
        }
    }
}
