//
//  ShoppingListView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-18.
//

import SwiftUI
import SwiftData

struct ShoppingListView: View {
    @Environment(\.modelContext) var context
    
    @Query() var shoppingLists: [ShoppingList]

    var body: some View {
        NavigationStack {
            @Bindable var shoppingList = shoppingLists.first!
            IngredientList(ingredients: shoppingList.getItems(), selections: $shoppingList.selections, onDelete: { indexSet in
                shoppingList.deleteItem(indexSet: indexSet, context: context)
            })
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
