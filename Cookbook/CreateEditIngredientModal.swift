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
    
    func onCreateIngredient() {
        keyboardIsActive = true
        if (ingredient.name.isEmpty) {return}
        ingredients.append(ingredient)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                CreateEditIngredient(ingredient: ingredient, onSubmit: onCreateIngredient, keyboardIsActive: $keyboardIsActive)
                if (!ingredients.isEmpty) {
                    Section {
                        List {
                            ForEach(ingredients) {ingredient in
                                IngredientCell(ingredient: ingredient)
                            }
                        }
                        
                    } header: {Text("Ingredients")}
                }
                
            }
            .onScrollPhaseChange { oldPhase, newPhase in
                if (oldPhase == .interacting) {
                    keyboardIsActive = false
                }
            }
            .navigationTitle("Ingredients")
            .toolbar{
                ToolbarItem {
                    Button {
                        if (!ingredient.name.isEmpty) {
                            ingredients.append(ingredient)
                        }
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
                
            }
        }
        
        
    }
}
//
//#Preview {
//    AddIngredientModal()
//}
