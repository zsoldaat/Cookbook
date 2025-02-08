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
    @State private var dateFilterViewShowing: Bool = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    
    @Query(sort: \Recipe.name) var recipes: [Recipe]
    
    func filterSearch(recipe: Recipe) -> Bool {
        var shouldFilter: Bool = true
        
        if (!searchValue.isEmpty) {
            if (
                !recipe.ingredients!
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
        
        if dateFilterViewShowing == true {
            let calendar = Calendar.current
            
            //if user has selected a date
            if (!calendar.isDate(startDate, inSameDayAs: Date()) || !calendar.isDate(endDate, inSameDayAs: Date())) {
                
                if recipe.date < startDate && !calendar.isDate(recipe.date, inSameDayAs: startDate) {
                    shouldFilter = false
                }
                
                if recipe.date > endDate && !calendar.isDate(recipe.date, inSameDayAs: endDate) {
                    shouldFilter = false
                }
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
                }
                .onDelete { indexSet in
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        filterViewShowing = true
                    } label: {
                        Label("Show Filters", systemImage: "line.3.horizontal.decrease.circle")
                            .labelStyle(.iconOnly)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addRecipeShowing = true
                    } label: {
                        Label("Add Recipe", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .fullScreenCover(isPresented: $addRecipeShowing) {
                @Bindable var recipe: Recipe = Recipe(name: "", instructions: "", ingredients: [])
                CreateEditRecipeView(recipe: recipe, isNewRecipe: true)
            }
        }
        .searchable(text: $searchValue, prompt: "Search...")
        .sheet(isPresented: $filterViewShowing) {
            FilterView(searchValue: $searchValue, ratingFilterValue: $ratingFilterValue, difficultyFilterValue: $difficultyFilterValue, dateFilterViewShowing: $dateFilterViewShowing, startDate: $startDate, endDate: $endDate)
        }
    }
    
}

//#Preview {
//    RecipeListView()
//}
