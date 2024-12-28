//
//  IngredientCell.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI

struct IngredientCell: View {
    
    let ingredient: Ingredient
    @State var selection: Int = 1
    
    var body: some View {
        HStack {
            Text(ingredient.name)
                .font(.headline)
            Text(ingredient.getString())
                .font(.subheadline)
        }.onTapGesture {
            ingredient.changeDisplayUnit()
        }.onAppear {
            ingredient.resetDisplayUnit()
        }
        
    }
}

#Preview {
    RecipeCell(recipe: Recipe(name: "Hello", instructions: "", ingredients: []))
}
