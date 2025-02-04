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
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    @StateObject var selectedTab: SelectedTab = SelectedTab(selectedTabTag: 0)
    @StateObject var dataController: DataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            SectionSelectView()
                .modelContainer(dataController.localContainer)
                .environmentObject(selectedTab)
                .environmentObject(dataController)
                .task {
                    await dataController.fetchSharedRecipes()
//                    let scraper = Scraper(url: URL(string: "https://tasty.co/recipe/one-pot-garlic-parmesan-pasta")!)
                }
        }
    }
}
