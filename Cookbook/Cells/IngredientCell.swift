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
            Text(ingredient.getString())
            .font(.subheadline)
        }.onTapGesture {
            ingredient.changeDisplayUnit()
        }
        
    }
}

#Preview {
    RecipeCell(recipe: Recipe(name: "Hello", instructions: "", ingredients: []))
}
