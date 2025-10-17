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
    @EnvironmentObject var dataController: DataController
    
    @State private var isShowingItemSheet = false
    @State private var recipeToEdit: Recipe?
    @State private var addRecipeShowing: Bool = false
    
    @State private var filterViewShowing: Bool = false
    
    @State private var searchValue: String = ""
    @State private var difficultyFilterValue: Float = 100
    @State private var selectedTags: Set<Tag> = []
    @State private var didChangeDates: Bool = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var sortBy: SortBy = .date
    @State private var sortDirectionDescending: Bool = false
    
    @Query(sort: \Recipe.name) var recipes: [Recipe]
    
    func filterSearch(recipe: Recipe) -> Bool {
        var shouldFilter: Bool = true
        
        if (!searchValue.isEmpty) {
            if (!recipe.name.lowercased().contains(searchValue.lowercased()) && !recipe.ingredients!
                .map{$0.name.lowercased()}
                .reduce("", {"\($0) \($1)"})
                .contains(searchValue.lowercased()))
            {
                shouldFilter = false
            }
        }
        
        if (difficultyFilterValue < 100) {
            
            if let recipeDifficulty = recipe.difficulty {
                if (recipeDifficulty > difficultyFilterValue) {
                    shouldFilter = false
                }
            }
        }
        
        if (selectedTags.count > 0) {
            
            let recipeTagIds = recipe.tags!.map{$0.id}
            let selectedTagIds = selectedTags.map{$0.id}
            
            if recipeTagIds.filter({selectedTagIds.contains($0)}).count == 0 {
                shouldFilter = false
            }
        }
        
        if didChangeDates == true {
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
                ForEach(recipes
                    .filter{filterSearch(recipe: $0)}
                    .sorted(by: { first, second in
                        switch sortBy {
                        case .name:
                            return sortDirectionDescending ? first.name < second.name : first.name > second.name
                        case .difficulty:
                            print(recipes.map{$0.difficulty})
                            let firstDifficulty = first.difficulty ?? 0
                            let secondDifficulty = second.difficulty ?? 0
                            return sortDirectionDescending ? firstDifficulty < secondDifficulty : firstDifficulty > secondDifficulty
                        case .date:
                            return sortDirectionDescending ? first.date < second.date : first.date > second.date
                        case .lastMade:
                            let firstLastMade = first.lastMadeDate ?? .distantPast
                            let secondLastMade = second.lastMadeDate ?? .distantPast
                            return sortDirectionDescending ? firstLastMade < secondLastMade : firstLastMade > secondLastMade
                        }
                    })) { recipe in
                        NavigationLink {
                            RecipeView(recipe: recipe)
                        } label: {
                            RecipeCell(recipe: recipe)
                                .swipeActions {
                                    if (!recipe.isShared) {
                                        Button(role: .destructive) {
                                            context.delete(recipe)
                                            try! context.save()
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                                .labelStyle(.iconOnly)
                                        }
                                        .tint(.red)
                                    } else {
                                        NavigationLink {
                                            GroupListView()
                                        } label: {
                                            Label("Manage shared group", systemImage: "person.2")
                                                .labelStyle(.iconOnly)
                                        }.tint(.yellow)
                                    }
                                }
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
            .refreshable {
                Task {
                    await dataController.addSharedGroupsToLocalContext()
                }
            }
            .fullScreenCover(isPresented: $addRecipeShowing) {
                @Bindable var recipe: Recipe = Recipe(name: "", instructions: "", ingredients: [])
                CreateEditRecipeView(recipe: recipe, isNewRecipe: true)
            }
        }
        .searchable(text: $searchValue, prompt: "Search...")
        .sheet(isPresented: $filterViewShowing) {
            FilterView(searchValue: $searchValue, difficultyFilterValue: $difficultyFilterValue, didChangeDates: $didChangeDates, startDate: $startDate, endDate: $endDate, selectedTags: $selectedTags, sortBy: $sortBy, sortDirectionDescending: $sortDirectionDescending)
        }
    }
}



//#Preview {
//    RecipeListView()
//}

