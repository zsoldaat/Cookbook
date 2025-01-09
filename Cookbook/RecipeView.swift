//
//  RecipeView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI
import SwiftData

let scaleFactors = ["1x", "2x", "3x", "4x"]

struct RecipeView: View {
    
    @Environment(\.modelContext) var context
    
    let recipe: Recipe
    
    @State private var editShowing: Bool = false
    
    @State private var selections = Set<UUID>()
    @State private var showAlert = false
    @State private var scaleFactor: Int = 1
    
    @FocusState var keyboardisActive: Bool
    
    @Query var shoppingLists: [ShoppingList]
    
    var body: some View {
        @Bindable var shoppingList = shoppingLists.first!
        
        
        ScrollView {
            RecipeImageView(recipe: recipe)
            
            CardView(title: "Instructions") {
                Text(recipe.instructions)
            }
            
            let actionButton = ActionButton(icon: "plus", disabled: selections.count == 0) {
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
            }
    
            CardView(title: "Ingredients", actionButton: actionButton) {
                
                let scaleBinding = Binding<String>(get: {
                    String(scaleFactor) + "x"
                }, set: {
                    scaleFactor = Int($0.prefix(1))!
                })
                
                HStack {
                    Spacer()
                    Picker("Scale", selection: scaleBinding) {
                        ForEach(scaleFactors, id: \.self) { factor in
                            Text(factor)
                        }
                    }
                }
                
                ForEach(recipe.ingredients) { ingredient in
                    HStack {
                        Image(systemName: selections.contains(ingredient.id) ? "circle.fill" : "circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
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
            //try to make it so this doesn't need to happen with the action button. Ideally bind
            // the 'disabled' property to selections.count
            .onChange(of: selections.count) { oldValue, newValue in
                actionButton.disabled = newValue == 0 ? true : false
            }
            
            CardView(title: "Details") {
                
                VStack(alignment: .leading) {
                    
                    if let timeCommitment = recipe.timeCommitment {
                        HStack {
                            Text("Time:").font(.headline)
                            Text(timeCommitment).font(.subheadline)
                        }
                    }
                    
                    if let lastMadeDate = recipe.lastMadeDate {
                        HStack {
                            Text("Last Made:").font(.headline)
                            Text(Recipe.dateFormatter.string(from:lastMadeDate)).font(.subheadline)
                        }
                    }
                }
            }
            
            if let link = recipe.link {
                if let url = URL(string:link) {
                    CardView(title: "Link") {
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
