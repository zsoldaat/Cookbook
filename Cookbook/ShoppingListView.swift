//
//  ShoppingListView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-18.
//

import SwiftUI

struct ShoppingListView: View {
    
    @EnvironmentObject var shoppingList: ShoppingList

    var body: some View {
        
        NavigationStack {
            IngredientList(ingredients: shoppingList.items, selections: $shoppingList.selections, editable: false)
                .navigationTitle("Shopping List")
                .toolbar {
                    Button {
                        shoppingList.clear()
                    } label: {
                        Text("Clear")
                    }
                }
        }
        
    }
}
