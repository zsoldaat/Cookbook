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
    
    @State var addShowing: Bool = false
    
    @FocusState var keyboardIsActive: Bool
    @StateObject var ingredient: Ingredient = Ingredient(name: "", quantityWhole: 1, quantityFraction: 0, unit: "item", index: 1)
    
    var body: some View {
        NavigationStack {
            @Bindable var shoppingList = shoppingLists.first!
            
            Form {
                
                if shoppingList.getItems().count > 0 {
                    IngredientListSection(ingredients: shoppingList.getItems(), selections: $shoppingList.selections, onDelete: { indexSet in
                        shoppingList.deleteItem(indexSet: indexSet, context: context)
                    })
                }
                
                ListButton(text: "Add", imageSystemName: "plus") {
                    addShowing = true
                }
            }
            .onScrollPhaseChange({ oldPhase, newPhase in
                if (oldPhase == .interacting) {
                    keyboardIsActive = false
                }
            })
            .sheet(isPresented: $addShowing, content: {
                NavigationStack {
                    Form {
                        CreateEditIngredient(ingredient: ingredient, onSubmit: {
                            ingredient.index = shoppingList.getNextIngredientIndex()
                            shoppingList.addItem(ingredient)
                            ingredient.name = ""
                            ingredient.quantityWhole = 1
                            ingredient.quantityFraction = 0
                            ingredient.unit = "item"
                            keyboardIsActive = true
                        }, keyboardIsActive: $keyboardIsActive)
                        
                        IngredientListSection(ingredients: shoppingList.getItems(), selections: $shoppingList.selections, onDelete: { indexSet in
                            shoppingList.deleteItem(indexSet: indexSet, context: context)
                        })
                    }
                    .toolbar {
                        Button {
                            addShowing = false
                        } label: {
                            Text("Done")
                        }
                    }
                }
                
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
