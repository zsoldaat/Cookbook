//
//  CloudKitController.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-27.
//

import SwiftUI
import CloudKit

class CloudKitController: ObservableObject {
    
    static var containerIdentifier: String = "iCloud.com.zacsoldaat.Cookbook"
    
    var container = CKContainer(identifier: CloudKitController.containerIdentifier)
    /// Sharing requires using a custom record zone.
    var recordZone = CKRecordZone(zoneName: "com.apple.coredata.cloudkit.zone")
    
    func fetchRecipes(scope: CKDatabase.Scope) async throws -> [Recipe] {
        
        var recipes: [Recipe] = []
        
        let zones = try await container.database(with: scope).allRecordZones()
        
        for zone in zones {
            let results = try await container.database(with: scope).records(matching: CKQuery(recordType: "CD_Recipe", predicate: NSPredicate(value: true)), inZoneWith: zone.zoneID, desiredKeys: nil, resultsLimit: 100).matchResults
            
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
            
        }

        return recipes
    }
    
    func fetchRecord(recipe: Recipe) async -> CKRecord? {
        guard let result = try! await container.privateCloudDatabase.records(matching: CKQuery(recordType: "CD_Recipe", predicate: NSPredicate(format: "CD_id == %@", recipe.id.uuidString))).matchResults.first else {return nil}
        
        let (recordId, record) = result
        
        do {
            let foundRecord = try record.get()
            return foundRecord
        } catch {
            print(error)
            return nil
        }
    }
    
    func fetchOrCreateShare(recipe: Recipe) async throws -> (CKShare, CKContainer)? {
        
        guard let associatedRecord = await fetchRecord(recipe: recipe) else {return nil}
        
        guard let existingShare = associatedRecord.share else {
            let share = CKShare(rootRecord: associatedRecord)
            share[CKShare.SystemFieldKey.title] = "Recipe: \(recipe.name)"
            _ = try await container.privateCloudDatabase.modifyRecords(saving: [associatedRecord, share], deleting: [])
            return (share, container)
        }
        
        guard let share = try await container.privateCloudDatabase.record(for: existingShare.recordID) as? CKShare else {
            throw MyError.runtimeError("search meee")
        }
        
        return (share, container)
        
    }
    
    enum MyError: Error {
        case runtimeError(String)
    }
    
    
}
