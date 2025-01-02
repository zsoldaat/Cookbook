//
//  RecipeView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI

struct RecipeView: View {
    
    let recipe: Recipe
    
    @State private var selectedSection: String = "Recipe"
    @State private var editShowing: Bool = false
    
    var body: some View {
        
        VStack {
            
            Picker("Section", selection: $selectedSection) {
                Text("Recipe").tag("Recipe")
                Text("Ingredients").tag("Ingredients")
            }
            .pickerStyle(.segmented)
            .padding()
            
            
            if (selectedSection == "Recipe") {
                List {
                    Section(header: Text("Instructions")) {
                        Text(recipe.instructions)
                    }
                }
            }
            
            if (selectedSection == "Ingredients") {
                IngredientListView(ingredients: recipe.ingredients)
            }
        }
        .navigationTitle(recipe.name)
        .sheet(isPresented: $editShowing, content: {
            @Bindable var recipe = recipe
            CreateRecipeView(recipe: recipe)
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editShowing = true
                } label: {
                    Text("Edit")
                }
            }
            
        }
        
        
    }
}
