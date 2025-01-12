//
//  RecipeView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI
import SwiftData

struct RecipeView: View {
    
    let recipe: Recipe
    
    @State private var editShowing: Bool = false

    @FocusState var keyboardisActive: Bool

    var body: some View {
        ScrollView {
            RecipeImageView(recipe: recipe)
            
            CardView(title: "Instructions") {
                Text(recipe.instructions)
            }
            
            IngredientsCard(recipe: recipe)
            
            
            
            CardView(title: "Difficulty") {
                let difficultyBinding = Binding<String>(get: {
                    if recipe.difficulty != nil {
                        return recipe.difficulty!
                    } else {
                        return ""
                    }
                }, set: {
                    recipe.difficulty = $0
                })
                
                Picker("Difficulty", selection: difficultyBinding) {
                    ForEach(["", "Easy", "Medium", "Hard"], id: \.self) { difficulty in
                        Text(difficulty)
                    }
                }
            }
            
            CardView(title: "Rating") {
                let ratingBinding = Binding<String>(get: {
                    if recipe.rating != nil {
                        return recipe.rating!
                    } else {
                        return ""
                    }
                }, set: {
                    recipe.rating = $0
                })
                
                Picker("Rating", selection: ratingBinding) {
                    ForEach(["", "Good", "Great"], id: \.self) { rating in
                        Text(rating)
                    }
                }
            }
            
            CardView(title: "Details") {
                VStack(alignment: .leading) {
                    if let lastMadeDate = recipe.lastMadeDate {
                        HStack {
                            Text("Last Made:").font(.headline)
                            Text(Recipe.dateFormatter.string(from:lastMadeDate)).font(.subheadline)
                        }
                    }
                    
                    if let link = recipe.link {
                        if let url = URL(string:link) {
                            HStack {
                                Text("Link:").font(.headline)
                                Link(link, destination: url).lineLimit(1).font(.subheadline)
                            }
                        }
                    }
                }
            }
        }
        .padding(2)
//        .alert("Ingredients Added", isPresented: $showAlert, actions: {})
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
