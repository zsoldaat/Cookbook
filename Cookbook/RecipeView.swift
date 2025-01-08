//
//  RecipeView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI
import SwiftData

struct RecipeView: View {
    
    @Environment(\.modelContext) var context
    
    let recipe: Recipe
    
    @State private var selectedSection: String = "Recipe"
    @State private var editShowing: Bool = false
    
    @State private var selections = Set<UUID>()
    @State private var showAlert = false
    
    @FocusState var keyboardisActive: Bool
    
    @Query var shoppingLists: [ShoppingList]
    
    var body: some View {
        
        VStack {
            @Bindable var shoppingList = shoppingLists.first!
            
            RecipeImageView(recipe: recipe)
            
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
                    
                    if let link = recipe.link {
                        Section(header: Text("Link")) {
                            Link(link,destination: URL(string: link)!)
                        }
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
                    IngredientList(ingredients: recipe.ingredients, selections: $selections)
                    Spacer()
                    Button {
                        
                        recipe.ingredients
                            .filter {item in
                                selections.contains(item.id)
                            }
                            .forEach {ingredient in
                                shoppingList.addItem(ingredient)
                            }
                        shoppingList.save(context: context)
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
        .fullScreenCover(isPresented: $editShowing, content: {
            @Bindable var recipe = recipe
            CreateEditRecipeView(recipe: recipe, isNewRecipe: false)
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
