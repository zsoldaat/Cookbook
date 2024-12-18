//
//  AddRecipeView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI

struct AddRecipeView: View {
    
    @Environment(\.modelContext) var context
    @EnvironmentObject var selectedTab: SelectedTab
    
    @State private var name: String = ""
    @State private var ingredients: [Ingredient] = []
    @State private var instructions: String = ""
    
    @State private var ingredientName: String = ""
    @State private var ingredientQuantity: String = ""
    @State private var ingredientUnit: String = "item"
    
    var units: [String] = [
        "item", "cup", "quart", "tsp", "tbsp", "ml", "l", "oz", "lb", "g", "kg", "pinch"
    ]
    
    var body: some View {
        NavigationStack {
            
            Form {
                Section {
                    TextField("Name", text: $name)
                }
                
                Section {
                    TextField("Instructions", text: $instructions, axis: .vertical)
                        .lineLimit(5...10)
                }
                
                Section {
                    TextField("Ingredient Name", text: $ingredientName)
                    
                    TextField("Quantity", text: $ingredientQuantity)
                        .keyboardType(.decimalPad)
                    
                    Picker("Ingredient Unit", selection: $ingredientUnit) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit)
                        }
                    }
                }
                
                Button {
                    ingredients.append(Ingredient(name: ingredientName, quantity: Double(ingredientQuantity) ?? 0, unit: ingredientUnit))
                    ingredientName = ""
                    ingredientQuantity = ""
                    ingredientUnit = "item"}
                label: {
                    HStack{
                        Spacer()
                        Text("Add Ingredient")
                        Spacer()
                    }
                }
                
                Section {
                    List {
                        ForEach(ingredients) {ingredient in
                            IngredientCell(ingredient: ingredient)
                        }.onDelete { indexSet in
                            ingredients.remove(atOffsets: indexSet)
                        }
                    }
                    
                } header: {Text("Ingredients")}
            }.toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let recipe = Recipe(name: name, instructions: instructions, ingredients: ingredients)
                        context.insert(recipe)
                        if context.hasChanges {
                            do {
                                try context.save()
                            } catch (let error) {
                                print(error)
                            }
                        }
                        selectedTab.selectedTabTag = 0
                    } label: {
                        Text("Save")
                    }
                }
            }
            
            
        }
    }
}
