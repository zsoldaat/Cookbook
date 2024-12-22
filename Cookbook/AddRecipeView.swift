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
    @State private var instructions: String = ""
    @State var ingredients: [Ingredient] = []
    
    @State private var ingredientModalShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            
            Form {
                Section {
                    TextField("", text: $name)
                } header: {
                    Text("Name")
                }
                
                Section {
                    TextField("", text: $instructions, axis: .vertical)
                        .lineLimit(5...10)
                } header: {
                    Text("Ingredient")
                }
                
                Button("+ Add Ingredients") {
                    ingredientModalShowing = true
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
            .sheet(isPresented: $ingredientModalShowing) {
                NavigationStack {
                    AddIngredientModal(ingredients: $ingredients)
                }
            }.onAppear {
                name = ""
                instructions = ""
            }
            .navigationTitle("New Recipe")
        }
    }
}
