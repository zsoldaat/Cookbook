//
//  AddEditIngredient.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-02.
//

import SwiftUI

struct CreateEditIngredient: View {
    
    @Bindable var ingredient: Ingredient
    @Binding var ingredients: [Ingredient]
    
    @FocusState private var keyboardIsActive: Bool
    
    private let units: [String] = [
        "item", "cup", "quart", "tsp", "tbsp", "mL", "L", "oz", "lb", "g", "kg", "pinch"
    ]
    
    private let fractions: [String] = [
        "", "1/8", "1/4", "1/3", "3/8", "1/2", "5/8", "2/3", "3/4", "7/8"
    ]
    
    var body: some View {
        Section("Name") {
            TextField("", text: $ingredient.name)
                .onSubmit {
                    keyboardIsActive = true
                    if (ingredient.name.isEmpty) {return}
                    ingredient.displayUnit = ingredient.unit
                    ingredients.append(ingredient)
                }
                .submitLabel(.done)
                .focused($keyboardIsActive)
                .onAppear {
                    keyboardIsActive = true
                }
        }.onScrollPhaseChange { oldPhase, newPhase in
            if (oldPhase == .interacting) {
                keyboardIsActive = false
            }
        }
        
        Section("Quantity") {
            HStack {
                
                Picker("Whole quantity", selection: $ingredient.quantityWhole) {
                    ForEach(0...10, id: \.self) { number in
                        Text(String(number))
                    }
                }.pickerStyle(.wheel)
                
                Picker("Fraction", selection: $ingredient.quantityFractionString) {
                    ForEach(fractions, id: \.self) { fraction in
                        Text(fraction)
                    }
                }.pickerStyle(.wheel)
                
                Picker("Unit", selection: $ingredient.unit) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit)
                    }
                }
                .pickerStyle(.wheel)
            }.frame(height: 120)
        }
        
    }
}
//
//#Preview {
//    CreateEditIngredient()
//}
