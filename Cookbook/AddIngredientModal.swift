//
//  AddIngredientModal.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-18.
//

import SwiftUI

struct AddIngredientModal: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var ingredients: [Ingredient]
    @Bindable var ingredient: Ingredient
    
    @FocusState private var keyboardIsActive: Bool
    
    private let units: [String] = [
        "item", "cup", "quart", "tsp", "tbsp", "mL", "L", "oz", "lb", "g", "kg", "pinch"
    ]
    
    private let fractions: [String] = [
        "", "1/8", "1/4", "1/3", "3/8", "1/2", "5/8", "2/3", "3/4", "7/8"
    ]
    
    private func addIngredients() {
        ingredients.append(ingredient)
    }
    
    var body: some View {
        Form {
            Section("Name") {
                TextField("", text: $ingredient.name)
                    .onSubmit {
                        keyboardIsActive = true
                        if (ingredient.name.isEmpty) {return}
                        addIngredients()
                    }
                    .submitLabel(.done)
                    .focused($keyboardIsActive)
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
                    }.pickerStyle(.wheel)
                }.frame(height: 120)
            }
            
            Section {
                List {
                    ForEach(ingredients) {ingredient in
                        IngredientCell(ingredient: ingredient)
                    }.onDelete { indexSet in
                        ingredients.remove(atOffsets: indexSet)
                    }
                }
                
            } header: {Text("Ingredients")}
            
        }
        .navigationTitle(Text("Ingredients"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }
            }
        }
        .onScrollPhaseChange { oldPhase, newPhase in
            
            if (oldPhase == .interacting) {
                keyboardIsActive = false
            }
        }
    }
}
//
//#Preview {
//    AddIngredientModal()
//}
