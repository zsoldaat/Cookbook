//
//  TabView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-18.
//

import SwiftUI

struct SectionSelectView: View {
    
    @EnvironmentObject var selectedTab: SelectedTab
    
    var body: some View {
        TabView(selection: $selectedTab.selectedTabTag) {
            RecipeListView()
                .tabItem {
                    HStack {
                        Image(systemName: "book")
                        Text("Recipes")
                    }
                }
                .tag(0)
            @Bindable var recipe = Recipe(name: "", instructions: "", ingredients: [] )
            CreateRecipeView(recipe: recipe)
                .tabItem {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                }
                .tag(1)
            ShoppingListView()
                .tabItem {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("Shopping List")
                    }
                }
                .tag(2)
        }
    }
    
    
}
