//
//  IngredientsCard.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-12.
//

import SwiftUI
import SwiftData

struct IngredientsCard: View {
    
    @Environment(\.modelContext) var context
    @Query var shoppingLists: [ShoppingList]
    
    let recipe: Recipe
    
    @State private var showAlert = false
    @State private var selections = Set<UUID>()
    @State private var scaleFactor: Int = 1
    @State private var parsedIngredientsShowing = false
    
    @State private var activeCardIndex: Int? = 0
    
    var body: some View {
        @Bindable var shoppingList = shoppingLists.first!
        
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                Group {
                    CardView(title: "Ingredients", button: {
                        Button {
                            recipe.ingredients
                            
                                .filter {item in
                                    selections.contains(item.id)
                                }
                                .forEach { ingredient in
                                    //add ingredients multiple times if scaling up the recipe
                                    for _ in 1...scaleFactor {
                                        shoppingList.addItem(ingredient)
                                    }
                                }
                            shoppingList.save(context: context)
                            selections.removeAll()
                            recipe.lastMadeDate = Date()
                            showAlert = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .disabled(selections.isEmpty)
                    }) {
                        
                        let scaleBinding = Binding<String>(get: {
                            String(scaleFactor) + "x"
                        }, set: {
                            scaleFactor = Int($0.prefix(1))!
                        })
                        
                        HStack {
                            Spacer()
                            Picker("Scale", selection: scaleBinding) {
                                ForEach( ["1x", "2x", "3x", "4x"], id: \.self) { factor in
                                    Text(factor)
                                }
                            }
                        }
                        
                        ForEach(recipe.ingredients.sorted {$0.index < $1.index}) { ingredient in
                            HStack {
                                Image(systemName: selections.contains(ingredient.id) ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                    .onTapGesture {
                                        if (selections.contains(ingredient.id)) {
                                            selections.remove(ingredient.id)
                                        } else {
                                            selections.insert(ingredient.id)
                                        }
                                    }
                                    .sensoryFeedback(trigger: selections.contains(ingredient.id)) { oldValue, newValue in
                                        return .increase
                                    }
                                IngredientCell(ingredient: ingredient, scaleFactor: $scaleFactor)
                            }
                            //Specify height to help the scrollview become the right size, maybe fix later to something dynamic?
                            .frame(height: 50)
                        }
                    }
                    .id(0)
                    
                    if let ingredientStrings = recipe.ingredientStrings {
                        CardView(title: "Ingredients (text)") {
                            ForEach(ingredientStrings, id: \.self) { ingredientString in
                                Text(ingredientString)
                            }
                            
                            Spacer()
                        }
                        .id(1)
                    }
                }
                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
            }
            .scrollTargetLayout()
        }
        .scrollDisabled(recipe.ingredientStrings == nil)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $activeCardIndex)
        .scrollIndicators(.hidden)
        .alert("Ingredients Added", isPresented: $showAlert, actions: {})
        
        if recipe.ingredientStrings != nil {
            HStack {
                Spacer()
                ForEach(0...1, id: \.self) {id in
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .padding(2)
                        .foregroundStyle(.gray)
                        .opacity(activeCardIndex == id ? 1 : 0.5)
                }
                Spacer()
            }
        }
    }
}
//
//#Preview {
//    IngredientsCard()
//}
