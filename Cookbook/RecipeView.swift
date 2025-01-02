//
//  RecipeView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI

struct RecipeView: View {
    
    let recipe: Recipe
    
    @State private var selectedSection: String = "Recipe"
    @State private var editShowing: Bool = false
    
    @EnvironmentObject var shoppingList: ShoppingList
    
    @State private var selections = Set<UUID>()
    @State private var showAlert = false
    
    @FocusState var keyboardisActive: Bool
    
    var body: some View {
        
        VStack {
            
            Picker("Section", selection: $selectedSection) {
                Text("Recipe").tag("Recipe")
                Text("Ingredients").tag("Ingredients")
            }
            .pickerStyle(.segmented)
            .padding()
            
            
            if (selectedSection == "Recipe") {
                List {
                    Section(header: Text("Instructions")) {
                        Text(recipe.instructions)
                    }
                }
            }
            
            if (selectedSection == "Ingredients") {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            selections.removeAll()
                        } label: {
                            Text("Clear selected")
                        }
                    }
                    IngredientList(ingredients: recipe.ingredients, selections: $selections, editable: true)
                    Spacer()
                    Button {
                        shoppingList.items.append(contentsOf: recipe.ingredients.filter{item in
                            selections.contains(item.id)
                        })
                        showAlert = true
                    } label: {
                        Text("Add selections to Shopping List")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(20)
                    .alert("Ingredients Added", isPresented: $showAlert, actions: {})
                }
            }
        }
        .navigationTitle(recipe.name)
        .sheet(isPresented: $editShowing, content: {
            @Bindable var recipe = recipe
            CreateEditRecipeView(recipe: recipe)
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editShowing = true
                } label: {
                    Text("Edit")
                }
            }
            
        }
        
        
    }
}
