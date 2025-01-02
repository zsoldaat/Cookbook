//
//  AddIngredientModal.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-18.
//

import SwiftUI

struct CreateEditIngredientModal: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var ingredients: [Ingredient]
    @Bindable var ingredient: Ingredient
    
    @FocusState private var keyboardIsActive: Bool
    
    func onCreate() {
        if (ingredient.name.isEmpty) {return}
        ingredient.displayUnit = ingredient.unit
        ingredients.append(ingredient)
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Done")
            }.padding()
        }
        
        Form {
            CreateEditIngredient(ingredient: ingredient, onCreate: onCreate, keyboardIsActive: $keyboardIsActive)
            if (!ingredients.isEmpty) {
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
            
        }
        .navigationTitle(Text("Ingredients"))
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
