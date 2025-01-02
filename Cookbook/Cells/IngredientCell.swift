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
    @State var displayUnit: String? = nil
    
    var body: some View {
        HStack {
            Text(ingredient.name)
                .font(.headline)
           Spacer()
            Text(ingredient.getString(displayUnit: displayUnit ?? ingredient.unit))
                .font(.subheadline)
                .onTapGesture {
                    displayUnit = ingredient.changeDisplayUnit(displayUnit: displayUnit ?? ingredient.unit)
                }
                .onLongPressGesture {
                    displayUnit = ingredient.unit
                }
        }
        .padding(10)
    }
}

#Preview {
    RecipeCell(recipe: Recipe(name: "Hello", instructions: "", ingredients: []))
}
