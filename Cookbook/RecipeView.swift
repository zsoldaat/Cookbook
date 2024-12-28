//
//  RecipeView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI

struct RecipeView: View {
    
    let recipe: Recipe
    
    var body: some View {
        
        NavigationStack {
            
            Text(recipe.instructions)
            
        }
        .navigationTitle(recipe.name)
        .toolbar {
            NavigationLink {
                IngredientListView(ingredients: recipe.ingredients)
            } label: {
                Text("Ingredients")
            }
        }
        
        
    }
}
