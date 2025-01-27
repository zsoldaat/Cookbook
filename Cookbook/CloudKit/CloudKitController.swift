//
//  CloudKitController.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-27.
//

import SwiftUI
import CloudKit

class CloudKitController: ObservableObject {
    
    static let container = CKContainer(identifier: "iCloud.com.zacsoldaat.Cookbook")
    /// This project uses the user's private database.
    static private let database = container.privateCloudDatabase
    /// Sharing requires using a custom record zone.
    static let recordZone = CKRecordZone(zoneName: "com.apple.coredata.cloudkit.zone")
    
    func fetchPrivateRecipes() async throws -> [Recipe] {
        
        let records: [Recipe] = []
        
        let recipes = try! await CloudKitController.container.privateCloudDatabase.records(matching: CKQuery(recordType: "CD_Recipe", predicate: NSPredicate(value: true))).matchResults
        
        recipes.forEach { record in
            let (recordId, result) = record
//            print(result.)
        }
        
//        let zones = try! await CloudKitController.container.privateCloudDatabase.fetch(withQuery: CKQuery(recordType: "CD_Recipe", predicate: NSPredicate(value: true)), completionHandler: { hello in
//            print("yayaya", hello)
//        })
//        let recipes = try! await fetchRecipes(scope: .private, in: zones)
        
//        return recipes
        return []
    }

}
