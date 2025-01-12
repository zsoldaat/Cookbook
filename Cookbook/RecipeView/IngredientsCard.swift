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
    
    var body: some View {
        @Bindable var shoppingList = shoppingLists.first!
        CardView(title: "Ingredients") {
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
        } content: {
            
            if (parsedIngredientsShowing == false) {
                
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
                }
            }
            
            if (parsedIngredientsShowing == true) {
                if let ingredientStrings = recipe.ingredientStrings {
                    ForEach(ingredientStrings, id: \.self) { ingredientString in
                        Text(ingredientString)
                    }
                }
            }
            
            Button {
                parsedIngredientsShowing.toggle()
            } label: {
                parsedIngredientsShowing ? Text("Show Ingredients") : Text("Show Raw Ingredients")
            }
        }
        .alert("Ingredients Added", isPresented: $showAlert, actions: {})
    }
}
//
//#Preview {
//    IngredientsCard()
//}
