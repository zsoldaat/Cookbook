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
    @StateObject var ingredient: Ingredient = Ingredient(name: "", quantityWhole: 1, quantityFraction: 0, unit: .item, index: 1)
    
    var body: some View {
        NavigationStack {
            @Bindable var shoppingList = shoppingLists.first!
            
            GeometryReader { geo in
                VStack {
                    CardView(title: "Items", button: {Button {
                        shoppingList.clear()
                    } label: {
                        Text("Clear")
                    }}) {
                        ForEach(shoppingList.getItems().sorted {$0.index < $1.index}) { ingredient in
                            HStack {
                                Image(systemName: shoppingList.selections.contains(ingredient.id) ? "circle.fill" : "circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25)
                                    .onTapGesture {
                                        if (shoppingList.selections.contains(ingredient.id)) {
                                            shoppingList.selections.remove(ingredient.id)
                                        } else {
                                            shoppingList.selections.insert(ingredient.id)
                                        }
                                    }
                                    .sensoryFeedback(trigger: shoppingList.selections.contains(ingredient.id)) { oldValue, newValue in
                                        return .increase
                                    }
                                IngredientCell(ingredient: ingredient)
                            }
                            .draggable(ingredient.id.uuidString) {
                                Text(ingredient.name)
                            }
                            .dropDestination(for: String.self) { uuids, location in
                                let uuid = uuids.first!
                                let draggedIngredient = shoppingList.getItems().first(where: { item in
                                    item.id.uuidString == uuid
                                })!.name
                                let droppedIngredient = ingredient.name
                                return true
                            }

                        }
                        .onDelete { indexSet in
                            shoppingList.deleteItem(indexSet: indexSet, context: context)
                        }
                        .onScrollPhaseChange({ oldPhase, newPhase in
                            if (oldPhase == .interacting) {
                                keyboardIsActive = false
                            }
                        })
                        Spacer()
                    }
                    .padding(.horizontal, 5)
                    
                    CardView(title: "Add") {
                        Button {
                            addShowing = true
                        } label: {
                            Text("Add")
                        }
                    }.padding(.horizontal, 5)
                }
            }
            .navigationTitle("Shopping List")
            .sheet(isPresented: $addShowing, content: {
                NavigationStack {
                    Form {
                        CreateEditIngredient(ingredient: ingredient, onSubmit: {
                            //make copy
                            shoppingList.addItem(Ingredient(name: ingredient.name, shoppingList: shoppingList, quantityWhole: ingredient.quantityWhole, quantityFraction: ingredient.quantityFraction, unit: ingredient.unit, index: shoppingList.getNextIngredientIndex()))
                            ingredient.name = ""
                            ingredient.quantityWhole = 1
                            ingredient.quantityFraction = 0
                            ingredient.unit = .item
                            keyboardIsActive = true
                            shoppingList.save(context: context)
                        }, keyboardIsActive: $keyboardIsActive)
                        
                        IngredientListSection(ingredients: shoppingList.getItems(), selections: $shoppingList.selections, onDelete: { indexSet in
                            shoppingList.deleteItem(indexSet: indexSet, context: context)
                        })
                    }
                }
                
            })
        }
    }
}
