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
        let schema = Schema([Recipe.self, ShoppingList.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        container.mainContext.insert(ShoppingList())
//        container.deleteAllData()
        return container
    }()
    
    @StateObject var selectedTab: SelectedTab = SelectedTab(selectedTabTag: 0)
    
    var body: some Scene {
        WindowGroup {
            SectionSelectView()
                .modelContainer(container)
                .environmentObject(selectedTab)
                .task {
                    let scraper = Scraper(url: URL(string: "https://www.halfbakedharvest.com/spicy-coconut-chicken-curry/")!)
                    await scraper.scrapeUrl()
                }
        }
        
        
    }
}
