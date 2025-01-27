//
//  CookbookApp.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI
import SwiftData
import FirebaseCore
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
//test
@main
struct CookbookApp: App {
    let container: ModelContainer = {
        let schema = Schema([Recipe.self, ShoppingList.self, Ingredient.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        let listCount = try! container.mainContext.fetchCount(FetchDescriptor<ShoppingList>())
        if listCount == 0 {
            container.mainContext.insert(ShoppingList())
        }
        //        container.deleteAllData()
        return container
    }()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var selectedTab: SelectedTab = SelectedTab(selectedTabTag: 0)
    @StateObject var authService: AuthService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            SectionSelectView()
                .modelContainer(container)
                .environmentObject(selectedTab)
                .environmentObject(authService)
                .task {
                    //                    let scraper = Scraper(url: URL(string: "https://tasty.co/recipe/one-pot-garlic-parmesan-pasta")!)
                    //                    let data = await scraper.getRecipeData()
                    //
                    //                    if let data = data {
                    //
                    //                        print(data.ingredients)
                    //
                    //                    }
//                    let cloudKitController = CloudKitController()
                    //                    let recipes = try! await cloudKitController.fetchPrivateRecipes()
                    //                    print("Hello", recipes)
                    //                    print(recipes.map {$0.name})
                    
                }
        }
        
        
    }
}
