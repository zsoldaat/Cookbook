//
//  RecipeCell.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI

struct RecipeCell: View {
    
    let recipe: Recipe
    
    var body: some View {
        Text(recipe.name)
    }
}

#Preview {
    RecipeCell(recipe: Recipe(name: "Hello", instructions: "", ingredients: []))
}
