//
//  ShoppingListView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-18.
//

import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @Query() var shoppingLists: [ShoppingList]

    var body: some View {
        NavigationStack {
            @Bindable var shoppingList = shoppingLists.first!
            IngredientList(ingredients: shoppingList.getItems(), selections: $shoppingList.selections)
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
