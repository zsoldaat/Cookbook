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
    @State private var ratingFilterValue: Rating = .none
    @State private var difficultyFilterValue: String = ""
    @State private var filterViewShowing: Bool = false
    
    @Query(sort: \Recipe.name) var recipes: [Recipe]
    
    func filterSearch(recipe: Recipe) -> Bool {
        var shouldFilter: Bool = true
        
        if (!searchValue.isEmpty) {
            if (
                !recipe.ingredients
                    .map{$0.name.lowercased()}
                    .reduce("", {"\($0) \($1)"})
                    .contains(searchValue.lowercased())
            ) {
                shouldFilter = false
            }
            
            if (!recipe.name.lowercased().contains(searchValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())) {
                shouldFilter = false
            }
        }
        
        if (ratingFilterValue != .none) {
            if (recipe.rating != ratingFilterValue) {
                shouldFilter = false
            }
        }
        
        if (!difficultyFilterValue.isEmpty) {
            if (recipe.difficulty != difficultyFilterValue) {
                shouldFilter = false
            }
        }
        
        return shouldFilter
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
            .navigationBarItems(
                leading: Button {
                    filterViewShowing = true
                } label: {
                    Label("Show Filters", systemImage: "line.3.horizontal.decrease.circle")
                        .labelStyle(.iconOnly)
                },
                trailing: Button {
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
        .sheet(isPresented: $filterViewShowing) {
            NavigationStack {
                Picker(selection: $ratingFilterValue) {
                    ForEach(Rating.allCases) { rating in
                        Text(rating.emoji()).tag(rating)
                    }
                } label: {
                    Label("Rating:", systemImage: "star.leadinghalf.filled")
                        .labelStyle(.titleOnly)
                }
                
                Picker(selection: $difficultyFilterValue) {
                    ForEach(["", "Easy", "Medium", "Hard"], id: \.self) { difficulty in
                        Text(difficulty).tag(difficulty)
                    }
                } label: {
                    Label("Difficulty", systemImage: "chart.bar.xaxis.ascending")
                        .labelStyle(.titleOnly)
                }
            }
        }
        
    }
    
}

#Preview {
    RecipeListView()
}
