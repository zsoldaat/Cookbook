//
//  AddRecipeView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI

struct CreateRecipeView: View {
    
    @Environment(\.modelContext) var context
    @EnvironmentObject var selectedTab: SelectedTab
    
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
                
                Section {
                    List {
                        ForEach(recipe.ingredients) {ingredient in
                            IngredientCell(ingredient: ingredient)
                        }.onDelete { indexSet in
                            recipe.ingredients.remove(atOffsets: indexSet)
                        }
                    }
                    
                } header: {Text("Ingredients")}
            }.toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        recipe.createUpdateRecipe(context: context)
                        selectedTab.selectedTabTag = 0
                    } label: {
                        Text("Save")
                    }
                }
            }
            .sheet(isPresented: $ingredientModalShowing) {
                AddIngredientModal(ingredients: $recipe.ingredients)
            }
            .navigationTitle("New Recipe")
            .scrollDismissesKeyboard(.immediately)
        }
    }
}
