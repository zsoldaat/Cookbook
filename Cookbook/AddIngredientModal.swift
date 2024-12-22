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
    
    @State private var ingredientName: String = ""
    @State private var ingredientQuantityWhole: Int = 1
    @State private var ingredientQuantityFraction: String = ""
    @State private var ingredientUnit: String = "item"
    
    @FocusState private var keyboardIsActive: Bool
    
    private let units: [String] = [
        "item", "cup", "quart", "tsp", "tbsp", "ml", "l", "oz", "lb", "g", "kg", "pinch"
    ]
    
    private let fractions: [String] = [
        "", "1/8", "1/4", "1/3", "3/8", "1/2", "5/8", "2/3", "3/4", "7/8"
    ]
    
    private func addIngredients() {
        ingredients.append(Ingredient(name: ingredientName, quantity: getQuantityDouble(), unit: ingredientUnit))
        ingredientName = ""
        ingredientQuantityWhole = 1
        ingredientQuantityFraction = ""
        ingredientUnit = "item"
    }
    
    private func getQuantityDouble() -> Double {
        return Double(ingredientQuantityWhole) + fractionToDouble(fraction: ingredientQuantityFraction)
    }
    
    private func fractionToDouble(fraction: String) -> Double {
        if (fraction.isEmpty) {return Double(0)}
        
        let numerator = Double(String(fraction.first!))!
        let denominator = Double(String(fraction.last!))!
        
        return numerator/denominator
        
    }
    
    var body: some View {
        Form {
            Section("Name") {
                TextField("", text: $ingredientName)
                    .onSubmit {
                        keyboardIsActive = true
                        if (ingredientName.isEmpty) {return}
                        addIngredients()
                    }
                    .submitLabel(.done)
                    .focused($keyboardIsActive)
            }
            
            Section("Quantity") {
                HStack {
                    
                    Picker("Whole quantity", selection: $ingredientQuantityWhole) {
                        ForEach(1...10, id: \.self) { number in
                            Text(String(number))
                        }
                    }.pickerStyle(.wheel)
                    
                    Picker("Fraction", selection: $ingredientQuantityFraction) {
                        ForEach(fractions, id: \.self) { fraction in
                            Text(fraction)
                        }
                    }.pickerStyle(.wheel)
                    
                    Picker("Unit", selection: $ingredientUnit) {
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
        .navigationTitle(Text("Add Ingredients"))
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
