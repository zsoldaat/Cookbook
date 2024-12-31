//
//  CookbookApp.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI
import SwiftData

@main
struct CookbookApp: App {
    let container: ModelContainer = {
        let scheme = Schema([Recipe.self])
        let container = try! ModelContainer(for: scheme, configurations: [])
//        container.deleteAllData()
        return container
    }()
    
    @StateObject var selectedTab: SelectedTab = SelectedTab(selectedTabTag: 0)
    @StateObject var shoppingList: ShoppingList = ShoppingList()
    
    var body: some Scene {
        WindowGroup {
            SectionSelectView()
                .modelContainer(container)
                .environmentObject(selectedTab)
                .environmentObject(shoppingList)
        }
        
        
    }
}
