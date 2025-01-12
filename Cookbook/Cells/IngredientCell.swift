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
            VStack(alignment: .leading) {
                Text(ingredient.name)
                if (!Unit.unconvertibleUnits().contains(ingredient.unit)) {
                    Text("\(ingredient.getQuantityString(displayUnit: displayUnit ?? ingredient.unit, scaleFactor: scaleFactor)) \(ingredient.getUnitString(displayUnit: displayUnit ?? ingredient.unit))")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            
           Spacer()

            //only show picker if units can actually be converted
            if (!Unit.unconvertibleUnits().contains(ingredient.unit)) {
                
                let unitBinding = Binding<Unit>(get: {
                    displayUnit ?? ingredient.unit
                }, set: {
                    displayUnit = $0
                })
                
                Picker("", selection: unitBinding) {
                    ForEach(ingredient.unit.possibleConversions().sorted(by: { unit1, unit2 in
                        //put original unit on top
                        if unit1 == ingredient.unit { return true }
                        return unit1.rawValue < unit2.rawValue
                    })) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .onChange(of: ingredient.unit) { oldValue, newValue in
                    displayUnit = newValue
                }
            }
        }
    }
}

//#Preview {
//    RecipeCell(recipe: Recipe(name: "Hello", instructions: "", ingredients: []))
//}
