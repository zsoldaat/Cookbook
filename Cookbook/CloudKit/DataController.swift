//
//  CloudKitController.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-27.
//

import SwiftUI
import CloudKit
import SwiftData

@MainActor
class DataController: ObservableObject {
    
    var localContainer: ModelContainer?
    
    static var cloudContainerIdentifier: String = "iCloud.com.zacsoldaat.Cookbook"
    
    private var cloudContainer = CKContainer(identifier: DataController.cloudContainerIdentifier)
    
    func addSharedGroupsToLocalContext() async {
        do {
            let sharedGroups = try await fetchGroups(scope: .shared)
            let localGroups = try localContainer!.mainContext.fetch(FetchDescriptor<RecipeGroup>())
            
            // Delete all shared groups from local
            localGroups.forEach { group in
                if group.isShared {
                    localContainer!.mainContext.delete(group)
                    
                    group.recipes?.forEach { recipe in
                        localContainer!.mainContext.delete(recipe)
                    }
                }
            }
            
            // Add them all back, with changes
            sharedGroups.forEach { sharedGroup in
                localContainer!.mainContext.insert(sharedGroup)
            }
            
            // This code below tries to actually update the local groups based on the incoming shared groups, but is not working right now so just deleting everything might be easier, we'll see
            
//            sharedGroups.forEach { sharedGroup in
//                let localGroupIds = localGroups.map{ $0.id.uuidString }
//
//                
//                if localGroupIds.contains(sharedGroup.id.uuidString) {
//                    // Update Recipes for shared groups that are already on the device
//                    let localGroup = localGroups.first(where: { $0.id.uuidString == sharedGroup.id.uuidString })!
//                    
//                    localGroup.recipes = []
//                    localGroup.recipes?.append(contentsOf: sharedGroup.recipes!)
//                } else {
//                    // Add groups (and their recipes) that don't exist on the device, mark the group and recipe as shared
//                    print("Happening")
//                    sharedGroup.isShared = true
//                    sharedGroup.recipes!.forEach { recipe in
//                        recipe.isShared = true
//                    }
//                    
//                    localContainer!.mainContext.insert(sharedGroup)
//                }
//            }

            try localContainer!.mainContext.save()
            
        } catch {
            print("Error fetching shared recipes.")
        }
    }
    
    private func fetchGroups(scope: CKDatabase.Scope) async throws -> [RecipeGroup] {
        var groups: [RecipeGroup] = []
        
        let zones = try await cloudContainer.database(with: scope).allRecordZones()
        
        for zone in zones {
            let groupResults = try await cloudContainer.database(with: scope).records(matching: CKQuery(recordType: "CD_RecipeGroup", predicate: NSPredicate(value: true)), inZoneWith: zone.zoneID).matchResults
            
            let groupsInZone = try groupResults.map {
                let (_, record) = $0
                let groupRecord = try record.get()
                return RecipeGroup(from: groupRecord)
            }
            
            groups.append(contentsOf: groupsInZone)
        }
        
        return groups
    }
    
    private func fetchRecordForGroup(group: RecipeGroup, scope: CKDatabase.Scope) async throws -> CKRecord? {
        
        let zones = try await cloudContainer.database(with: scope).allRecordZones()
        
        for zone in zones {
            if let result = try! await cloudContainer.database(with: scope).records(matching: CKQuery(recordType: "CD_RecipeGroup", predicate: NSPredicate(format: "CD_id == %@", group.id.uuidString)), inZoneWith: zone.zoneID).matchResults.first {
                
                let (_, record) = result
                
                do {
                    let record = try record.get()
                    return record
                    
                } catch {
                    print(error)
                    return nil
                }
            }
        }
        
        return nil
    }
    
    func updateRecipesForSharedGroup(group: RecipeGroup) async throws {
        if let groupRecord = try await fetchRecordForGroup(group: group, scope: .shared) {
            groupRecord.setValue(group.encodedRecipes, forKey: "CD_encodedRecipes")
            try await cloudContainer.sharedCloudDatabase.save(groupRecord)
        }
    }
    
    private func addSharedGroupsToLocalContext(group: RecipeGroup, scope: CKDatabase.Scope) async throws -> CKRecord? {
        
        let zones = try await cloudContainer.database(with: scope).allRecordZones()
        
        for zone in zones {
            if let result = try! await cloudContainer.database(with: scope).records(matching: CKQuery(recordType: "CD_RecipeGroup", predicate: NSPredicate(format: "CD_id == %@", group.id.uuidString)), inZoneWith: zone.zoneID).matchResults.first {
                
                let (_, record) = result
                
                do {
                    let groupRecord = try record.get()
                    return groupRecord
                } catch {
                    print(error)
                    return nil
                }
            }
        }
        
        return nil
    }
    
    func fetchOrCreateGroupShare(group: RecipeGroup, scope: CKDatabase.Scope) async throws -> (CKShare, CKContainer)? {
        if group.isShared {
            let shareReference = try await fetchRecordForGroup(group: group, scope: .shared)?.share
            
            guard let share = try await cloudContainer.sharedCloudDatabase.record(for: shareReference!.recordID) as? CKShare else {
                print("Could not get share")
                return nil
            }
            
            return (share, cloudContainer)
        }
        
        guard let associatedRecord = try await fetchRecordForGroup(group: group, scope: scope) else {
            print("Could not find associated group record")
            
            return nil
        }
        
        group.isShared = true
        associatedRecord.setValue(true, forKey: "CD_isShared")
        
        guard let existingShare = associatedRecord.share else {
            let share = CKShare(rootRecord: associatedRecord)
            share[CKShare.SystemFieldKey.title] = "Group: \(group.name)"
            
            _ = try await cloudContainer.privateCloudDatabase.modifyRecords(saving: [associatedRecord, share], deleting: [])
            return (share, cloudContainer)
        }
        
        guard let share = try await cloudContainer.privateCloudDatabase.record(for: existingShare.recordID) as? CKShare else {
            throw MyError.runtimeError("search meee")
        }
        
        return (share, cloudContainer)
        
    }
    
    enum MyError: Error {
        case runtimeError(String)
    }
}
