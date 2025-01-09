//
//  IngredientCell.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI

struct IngredientCell: View {
    
    let ingredient: Ingredient
    @Binding var scaleFactor: Int
    @State var displayUnit: String? = nil
    
    
    init(ingredient: Ingredient, scaleFactor: Binding<Int>? = nil) {
        self.ingredient = ingredient
        if let scaleFactor = scaleFactor {
            _scaleFactor = scaleFactor
        } else {
            _scaleFactor = .constant(1)
        }
    }
    
    
    var body: some View {
        HStack {
            Text(ingredient.name)
                .font(.headline)
           Spacer()
            Text(ingredient.getString(displayUnit: displayUnit ?? ingredient.unit, scaleFactor: scaleFactor))
                .font(.subheadline)
                .onTapGesture {
                    displayUnit = ingredient.changeDisplayUnit(displayUnit: displayUnit ?? ingredient.unit)
                }
                .onLongPressGesture {
                    displayUnit = ingredient.unit
                }
                .onChange(of: ingredient.unit) { oldValue, newValue in
                    displayUnit = newValue
                }
        }
        .padding(10)
    }
}

#Preview {
    RecipeCell(recipe: Recipe(name: "Hello", instructions: "", ingredients: []))
}
