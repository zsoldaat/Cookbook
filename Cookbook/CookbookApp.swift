//
//  CookbookApp.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI
import SwiftData
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, configurationForConnecting
        connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        // Create a scene configuration object for the
        // specified session role.
        let config = UISceneConfiguration(name: nil,
            sessionRole: connectingSceneSession.role)

        // Set the configuration's delegate class to the
        
        // scene delegate that implements the share
        // acceptance method.
        config.delegateClass = SceneDelegate.self

        return config
    }
    
}

@main
struct CookbookApp: App {
    
    let localContainer: ModelContainer = {
        let schema = Schema([RecipeGroup.self, Recipe.self, ShoppingList.self, Ingredient.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        container.mainContext.autosaveEnabled = true
        
        let listCount = try! container.mainContext.fetchCount(FetchDescriptor<ShoppingList>())
        if listCount == 0 {
            container.mainContext.insert(ShoppingList())
        }
        
//        container.deleteAllData()
                
        return container
    }()
    
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    @StateObject var selectedTab: SelectedTab = SelectedTab(selectedTabTag: 0)
    @StateObject var dataController: DataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            SectionSelectView()
                .modelContainer(localContainer)
                .environmentObject(selectedTab)
                .environmentObject(dataController)
                .task {
                    dataController.localContainer = localContainer
                    await dataController.addSharedGroupsToLocalContext()
                    // Fetch shared groups when the time comes and I can use Nathalie's phone to do more testing
//                    let groups = try! await dataController.fetchGroups2(scope: .private)
//                    await dataController.fetchSharedGroups()
//                    let scraper = Scraper(url: URL(string: "https://tasty.co/recipe/one-pot-garlic-parmesan-pasta")!)
                }
        }
    }
}
