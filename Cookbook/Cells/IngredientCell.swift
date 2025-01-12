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
    @State var displayUnit: Unit? = nil
    
    
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
            
            Text(ingredient.getQuantityString(displayUnit: displayUnit ?? ingredient.unit, scaleFactor: scaleFactor))
            
            
            
            if (!Unit.unconvertibleUnits().contains(ingredient.unit)) {
                
                let unitBinding = Binding<Unit>(get: {
                    displayUnit ?? ingredient.unit
                }, set: {
                    displayUnit = $0
                })
                
                Picker("", selection: unitBinding) {
                    ForEach(Unit.allCases) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .onChange(of: ingredient.unit) { oldValue, newValue in
                    displayUnit = newValue
                }
            }
            
            
            
            
//            Text("\(ingredient.getQuantityString(displayUnit: displayUnit ?? ingredient.unit, scaleFactor: scaleFactor)) \(ingredient.getUnitString(displayUnit: displayUnit ?? ingredient.unit))")
//                .font(.subheadline)
//                .onTapGesture {
//                    displayUnit = ingredient.changeDisplayUnit(displayUnit: displayUnit ?? ingredient.unit)
//                }
//                .onLongPressGesture {
//                    displayUnit = ingredient.unit
//                }
//                .onChange(of: ingredient.unit) { oldValue, newValue in
//                    displayUnit = newValue
//                }
        }
        .padding(10)
    }
}

//#Preview {
//    RecipeCell(recipe: Recipe(name: "Hello", instructions: "", ingredients: []))
//}
