//
//  AddIngredientModal.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-18.
//

import SwiftUI

struct CreateEditIngredientModal: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var ingredients: [Ingredient]
    @Bindable var ingredient: Ingredient
    var onAdd: ((Ingredient) -> Void)?
    
    @FocusState private var keyboardIsActive: Bool
    
    func onCreateIngredient() {
        keyboardIsActive = true
        if (ingredient.name.isEmpty) {return}
        if let onAdd = onAdd {
            onAdd(ingredient)
        }
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
                            if let onAdd = onAdd {
                                onAdd(ingredient)
                            }
                        }
                        
                        dismiss()
                        
                    } label: {
                        Label("Done", systemImage: "return.left").labelStyle(.titleOnly)
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
