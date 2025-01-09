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
    
    
    @State private var editShowing: Bool = false
    
    @State private var selections = Set<UUID>()
    @State private var showAlert = false
    
    @FocusState var keyboardisActive: Bool
    
    @Query var shoppingLists: [ShoppingList]
    
    var body: some View {
        @Bindable var shoppingList = shoppingLists.first!
        
        ScrollView {
            RecipeImageView(recipe: recipe)
            
            CardView(title: "Instructions") {
                Text(recipe.instructions)
            }
            
            IngredientListSection(ingredients: recipe.ingredients, selections: $selections)
            
            if (selections.count > 0) {
                ListButton(text: "Add ingredients to Shoppping List", imageSystemName: "plus") {
                    recipe.ingredients
                        .filter {item in
                            selections.contains(item.id)
                        }
                        .forEach {ingredient in
                            shoppingList.addItem(ingredient)
                        }
                    shoppingList.save(context: context)
                    selections.removeAll()
                    showAlert = true
                }
            }
            
            if let link = recipe.link {
                if let url = URL(string:link) {
                    Section(header: Text("Link")) {
                        Link(link, destination: url)
                    }
                }
            }
        }
//        .navigationTitle(recipe.name)
        .alert("Ingredients Added", isPresented: $showAlert, actions: {})
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
