//
//  CloudKitController.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-27.
//

import SwiftUI
import CloudKit

class CloudKitController: ObservableObject {
    
    let container = CKContainer(identifier: "iCloud.com.zacsoldaat.Cookbook")
    /// Sharing requires using a custom record zone.
    let recordZone = CKRecordZone(zoneName: "com.apple.coredata.cloudkit.zone")
    
    func fetchPrivateRecipes() async throws -> [Recipe] {
        
        var recipes: [Recipe] = []
        
        let results = try! await container.privateCloudDatabase.records(matching: CKQuery(recordType: "CD_Recipe", predicate: NSPredicate(value: true))).matchResults
        
        results.forEach {result in
            let (recordId, record) = result
            
            do {
                let foundRecord = try record.get()
                let recipe = Recipe(from: foundRecord)
                recipes.append(recipe)
            } catch {
                print(error)
            }
        }
        return recipes
    }
}
