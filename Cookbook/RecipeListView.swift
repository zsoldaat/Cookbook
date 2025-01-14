//
//  RecipeList.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI
import SwiftData

struct RecipeListView: View {
    
    @Environment(\.modelContext) var context
    
    @State private var isShowingItemSheet = false
    @State private var recipeToEdit: Recipe?
    @State private var addRecipeShowing: Bool = false
    
    @Query(sort: \Recipe.name) var recipes: [Recipe]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(recipes) { recipe in
                    NavigationLink {
                        RecipeView(recipe: recipe)
                    } label: {
                        RecipeCell(recipe: recipe)
                    }
                }.onDelete { indexSet in
                    for i in indexSet {
                        context.delete(recipes[i])
                    }
                    do {
                        try context.save()
                    } catch {
                        print("error")
                    }
                    
                }
            }
            .navigationTitle("Recipes")
            .navigationBarItems(trailing: Button {
                addRecipeShowing = true
            } label: {
                Image(systemName: "plus")
            })
            .fullScreenCover(isPresented: $addRecipeShowing) {
                @Bindable var recipe: Recipe = Recipe(name: "", instructions: "", ingredients: [])
                CreateEditRecipeView(recipe: recipe, isNewRecipe: true)
            }
        }
        
    }
    
}

#Preview {
    RecipeListView()
}
