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
    
    var cloudContainer = CKContainer(identifier: DataController.cloudContainerIdentifier)
    
    
    enum MyError: Error {
        case runtimeError(String)
    }
    
    func fetchSharedGroups() async {
        do {
            let groups = try await fetchGroups(scope: .shared)
            
            let localGroups = try localContainer!.mainContext.fetch(FetchDescriptor<RecipeGroup>())
            
            groups.forEach { group in
                let localGroupIds = localGroups.map{ $0.id.uuidString }
                
                if !localGroupIds.contains(group.id.uuidString) {
                    localContainer!.mainContext.insert(group)
                }
            }
            
            try localContainer!.mainContext.save()
            
        } catch {
            print("Error fetching shared recipes.")
        }
    }
    
    func fetchGroups(scope: CKDatabase.Scope) async throws -> [RecipeGroup] {
        
        var groups: [RecipeGroup] = []
        
        let zones = try await cloudContainer.database(with: scope).allRecordZones()
        
        for zone in zones {
            //fetch all groups, recipes, and ingredients
            let groupResults = try await cloudContainer.database(with: scope).records(matching: CKQuery(recordType: "CD_RecipeGroup", predicate: NSPredicate(value: true)), inZoneWith: zone.zoneID).matchResults
            let recipeResults = try await cloudContainer.database(with: scope).records(matching: CKQuery(recordType: "CD_Recipe", predicate: NSPredicate(value: true)), inZoneWith: zone.zoneID).matchResults
            let ingredientResults = try await cloudContainer.database(with: scope).records(matching: CKQuery(recordType: "CD_Ingredient", predicate: NSPredicate(value: true)), inZoneWith: zone.zoneID).matchResults
            let CDMRResults = try await cloudContainer.database(with: scope).records(matching: CKQuery(recordType: "CDMR", predicate: NSPredicate(value: true)), inZoneWith: zone.zoneID).matchResults
            
            // Use CDMR Records to create many to many relationships between groups and recipes
            
            let groupsInZone = try groupResults.map {
                let (_, record) = $0
                let groupRecord = try record.get()
                
                let recipeNamesInGroup = try CDMRResults
                    .filter { (_, record) in
                        let CDMRRecord = try record.get()
                        return CDMRRecord.parent?.recordID == groupRecord.recordID
                    }.map { (_, record) in
                        let recordNames = try record.get()["CD_recordNames"] as! String
                        return String(recordNames.split(separator: ":").first!)
                    }
                
                let recipesInGroup = try recipeResults.filter{ (recordId, _) in
                    return recipeNamesInGroup.contains(recordId.recordName)
                }.map { (record_id, recipeRecord) in
                    
                    let ingredientsInRecipe = try ingredientResults.filter { (_, record) in
                        let ingredientRecord = try record.get()
                        return ingredientRecord["CD_recipe"] == record_id.recordName
                    }.map { (_, record) in
                        let ingredientRecord = try record.get()
                        return Ingredient(from: ingredientRecord)
                    }
                    
                    return Recipe(from: try recipeRecord.get(), ingredients: ingredientsInRecipe)
                }
                
                return RecipeGroup(from: try record.get(), recipes: recipesInGroup)
            }
            groups.append(contentsOf: groupsInZone)
        }
        return groups
    }
    
    func setRelationShipsForGroup(groupRecord: CKRecord, zone: CKRecordZone) async throws {
        
        //change this to use NSPRedicate to only fetch relevant records vs filtering after, the CONTAINS keyword doesn't work here for some reasson. Might be because it's expecting an array?
        let relationshipsForGroup = try await cloudContainer.privateCloudDatabase.records(matching: CKQuery(recordType: "CDMR", predicate: NSPredicate(value: true)), inZoneWith: zone.zoneID).matchResults
            .filter { (_, record) in
                let recordNames = try record.get()["CD_recordNames"] as! String
                return recordNames.contains(groupRecord.recordID.recordName)
            }
        
        // Set parents for all the relationships
        for relationship in relationshipsForGroup {
            let (_, record) = relationship
            let relationshipRecord = try record.get()
            if relationshipRecord.parent?.recordID == nil {
                relationshipRecord.setParent(groupRecord)
                try! await cloudContainer.privateCloudDatabase.save(relationshipRecord)
            }
        }
        
        let recordNamesInGroup = try relationshipsForGroup
            .map { (_, record) in
                let recordNames = try record.get()["CD_recordNames"] as! String
                return String(recordNames.split(separator: ":").first!)
            }
        
        // Again, don't filter, use predicate. Can't get it to work because NSPredicate is annoying as fuck to use.
        let recipesInGroup = try await cloudContainer.privateCloudDatabase.records(matching: CKQuery(recordType: "CD_Recipe", predicate: NSPredicate(value: true)), inZoneWith: zone.zoneID).matchResults
            .filter { (recordId, _) in
                return recordNamesInGroup.contains(recordId.recordName)
            }
        
        let allIngredients = try await cloudContainer.privateCloudDatabase.records(matching: CKQuery(recordType: "CD_Ingredient", predicate: NSPredicate(value: true)), inZoneWith: zone.zoneID).matchResults
        
        for recipe in recipesInGroup {
            let (recordId, record) = recipe
            let recipeRecord = try record.get()
            
            let ingredientsInRecipe = try allIngredients.filter { (_, record) in
                return try record.get()["CD_recipe"] == recordId.recordName
            }
            
            for ingredient in ingredientsInRecipe {
                let (_, record) = ingredient
                let ingredientRecord = try record.get()
                if ingredientRecord.parent?.recordID == nil {
                    ingredientRecord.setParent(recordId)
                    try! await cloudContainer.privateCloudDatabase.save(ingredientRecord)
                }
            }
            
            if recipeRecord.parent?.recordID == nil {
                recipeRecord.setParent(groupRecord.recordID)
                try await cloudContainer.privateCloudDatabase.save(recipeRecord)
            }
        }
    }
    
    func fetchGroupRecord(group: RecipeGroup, scope: CKDatabase.Scope) async throws -> CKRecord? {
        
        let zones = try await cloudContainer.database(with: scope).allRecordZones()
        
        for zone in zones {
            if let result = try! await cloudContainer.database(with: scope).records(matching: CKQuery(recordType: "CD_RecipeGroup", predicate: NSPredicate(format: "CD_id == %@", group.id.uuidString)), inZoneWith: zone.zoneID).matchResults.first {
                
                let (_, record) = result
                
                do {
                    let groupRecord = try record.get()
                    
                    // Set parent relationships whenever you fetch. SwiftData doesn't set the relationships in iCloud for some reason, and they really only matter for sharing so you might as well fetch them when you're about to share something.
                    // Also only do this if you're fetching a private record, shared records will already have the relationships created
                    if scope == .private {
                        try await setRelationShipsForGroup(groupRecord: groupRecord, zone: zone)
                    }
                    
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
            let shareReference = try await fetchGroupRecord(group: group, scope: .shared)?.share
            
            guard let share = try await cloudContainer.sharedCloudDatabase.record(for: shareReference!.recordID) as? CKShare else {
                print("Could not get share")
                return nil
            }
            
            return (share, cloudContainer)
        }
        
        guard let associatedRecord = try await fetchGroupRecord(group: group, scope: scope) else {
            print("Could not find associated group record")
            
            return nil
        }
        
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
}
