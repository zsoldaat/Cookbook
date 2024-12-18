//
//  IngredientCell.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI

struct IngredientCell: View {
    
    let ingredient: Ingredient
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(ingredient.name)
                .font(.headline)
            HStack {
                Text(String(ingredient.quantity))
                Text(ingredient.unit)
            }
            .font(.subheadline)
            
        }
        
    }
}

#Preview {
    RecipeCell(recipe: Recipe(name: "Hello", instructions: "", ingredients: []))
}
