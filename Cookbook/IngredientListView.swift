//
//  IngredientListView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//


import SwiftUI

struct IngredientListView: View {
    
    @EnvironmentObject var shoppingList: ShoppingList
    
    let ingredients: [Ingredient]
    
    @State private var selections = Set<UUID>()
    @State private var showAlert = false
    
    var body: some View {
        
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        selections.removeAll()
                    } label: {
                        Text("Clear selected")
                    }
                }
                IngredientList(ingredients: ingredients, selections: $selections)
                Spacer()
                Button {
                    shoppingList.items.append(contentsOf: ingredients.filter{item in
                        selections.contains(item.id)
                    })
                    showAlert = true
                } label: {
                    Text("Add selections to Shopping List")
                }
                .buttonStyle(.borderedProminent)
                .padding(20)
                .alert("Ingredients Added", isPresented: $showAlert, actions: {})
            }
            
        }
    }
}
