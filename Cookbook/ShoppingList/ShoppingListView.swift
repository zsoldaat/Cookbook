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
    @State var errorShowing: Bool = false
    @State var clearAlertShowing: Bool = false
    
    @FocusState var keyboardIsActive: Bool
    @StateObject var ingredient: Ingredient = Ingredient(name: "", quantityWhole: 1, quantityFraction: 0, unit: .item, index: 1)
    
    var body: some View {
        NavigationStack {
            @Bindable var shoppingList = shoppingLists.first!
            
            VStack {
                CardView() {
                    ScrollView {
                        ForEach(shoppingList.getItems().sorted {$0.index < $1.index}) { ingredient in
                            HStack {
                                Button {
                                    if (shoppingList.selections.contains(ingredient.id)) {
                                        shoppingList.selections.remove(ingredient.id)
                                    } else {
                                        shoppingList.selections.insert(ingredient.id)
                                    }
                                } label: {
                                    Image(systemName: shoppingList.selections.contains(ingredient.id) ? "checkmark.circle.fill" : "circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25)
                                }
                                .sensoryFeedback(trigger: shoppingList.selections.contains(ingredient.id)) { oldValue, newValue in
                                    return .increase
                                }
                                    
                                IngredientCell(ingredient: ingredient)
                            }
                            .contentShape(Rectangle())
                            .draggable(ingredient.id.uuidString) {
                                Text(ingredient.name)
                            }
                            .dropDestination(for: String.self) { uuids, location in
                                let uuid = uuids.first!
                                let draggedIngredient = shoppingList.getItems().first(where: { item in
                                    item.id.uuidString == uuid
                                })!
                                let targetIngredient = ingredient
                                
                                if (draggedIngredient.id == targetIngredient.id) { return false }
                                
                                if (targetIngredient.unit.possibleConversions().contains(draggedIngredient.unit)) {
                                    let newIngredient = Ingredient(name: targetIngredient.name, quantityWhole: draggedIngredient.quantityWhole, quantityFraction: draggedIngredient.quantityFraction, unit: draggedIngredient.unit, index: shoppingList.getNextIngredientIndex())
                                    shoppingList.addItem(newIngredient)
                                    shoppingList.removeById(ids: [draggedIngredient.id])
                                } else {
                                    errorShowing = true
                                }
                                
                                return true
                            }
                        }
                        .onScrollPhaseChange({ oldPhase, newPhase in
                            if (oldPhase == .interacting) {
                                keyboardIsActive = false
                            }
                        })
                        
                        Spacer()
                    }
                }
                .padding([.bottom, .horizontal])
            }
            .alert("These units of these ingredients can't be added together.", isPresented: $errorShowing, actions: {})
            .alert(isPresented: $clearAlertShowing) {
                Alert(
                    title: Text("Are you sure you want to clear your grocery list?"),
                    primaryButton:
                            .default(Text("Yes"), action: {
                                shoppingList.clear()
                                clearAlertShowing = false
                            }),
                    secondaryButton: .cancel())
            }
            .navigationTitle("Shopping List")
            .toolbar {
                if (!shoppingList.selections.isEmpty) {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .destructive) {
                            shoppingList.removeById(ids: Array(shoppingList.selections))
                            shoppingList.selections.removeAll()
                        } label: {
                            Label("Remove", systemImage: "xmark.circle")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        clearAlertShowing = true
                    } label: {
                        Label("Clear", systemImage: "trash")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addShowing = true
                    } label: {
                        Label("Add", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .sheet(isPresented: $addShowing, content: {
                NavigationStack {
                    Form {
                        CreateEditIngredient(ingredient: ingredient, onSubmit: {
                            //make copy
                            shoppingList.addItem(Ingredient(name: ingredient.name, quantityWhole: ingredient.quantityWhole, quantityFraction: ingredient.quantityFraction, unit: ingredient.unit, index: shoppingList.getNextIngredientIndex()))
                            ingredient.name = ""
                            ingredient.quantityWhole = 1
                            ingredient.quantityFraction = 0
                            ingredient.unit = .item
                            keyboardIsActive = true
                            shoppingList.save(context: context)
                        }, keyboardIsActive: $keyboardIsActive)
                        
                        Section(header: Text("Ingredients")) {
                            ForEach(shoppingList.getItems().sorted {$0.index < $1.index}) { ingredient in
                                IngredientCell(ingredient: ingredient)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            shoppingList.deleteItem(item: ingredient)
                                            try! context.save()
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                                .labelStyle(.iconOnly)
                                        }
                                        .tint(.red)
                                    }
                            }
                        }
                    }
                }
                
            })
        }
    }
}
