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
    @State private var searchValue: String = ""
    
    @Query(sort: \Recipe.name) var recipes: [Recipe]
    
    func filterSearch(recipe: Recipe) -> Bool {
        if searchValue.isEmpty {return true}
        
        print(recipe.ingredients
            .map{$0.name.lowercased()}
            .reduce("", {"\($0) \($1)"}))
        
        if (
            recipe.ingredients
                .map{$0.name.lowercased()}
                .reduce("", {"\($0) \($1)"})
                .contains(searchValue.lowercased())
        ) {
            return true
        }
        
        return recipe.name.lowercased().contains(searchValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(recipes.filter {filterSearch(recipe: $0)}) { recipe in
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
                Label("Add Recipe", systemImage: "plus")
                    .labelStyle(.iconOnly)
            })
            .fullScreenCover(isPresented: $addRecipeShowing) {
                @Bindable var recipe: Recipe = Recipe(name: "", instructions: "", ingredients: [])
                CreateEditRecipeView(recipe: recipe, isNewRecipe: true)
            }
        }
        .searchable(text: $searchValue, prompt: "Search...")
        
    }
    
}

#Preview {
    RecipeListView()
}
