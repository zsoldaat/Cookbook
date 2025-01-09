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
                    let scraper = Scraper(url: URL(string: "https://www.halfbakedharvest.com/tomato-peach-and-burrata-salad/")!)
                    if let data = await scraper.getRecipeData() {
//                        print(data.name)
//                        print(data.instructions)
//                        print(data.ingredients)
//                        print(data.imageUrls?.first!)
                    }
                    
//                    if let title = await scraper.getTitle() {
//                        print(title)
//                    }
//                    if let instructions = await scraper.getInstructions() {
//                        print(instructions)
//                    }
                    // https://www.halfbakedharvest.com/spicy-coconut-chicken-curry/
                    
                    // https://eatsbyramya.com/recipes/chili-garlic-peanut-noodles/
                }
        }
        
        
    }
}
