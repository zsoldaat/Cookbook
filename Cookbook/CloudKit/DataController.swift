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
            let sharedGroups: [CKRecord] = try await fetchGroupRecords(scope: .shared)
            let localGroups: [RecipeGroup] = try localContainer!.mainContext.fetch(FetchDescriptor<RecipeGroup>())
            let localRecipes: [Recipe] = try localContainer!.mainContext.fetch(FetchDescriptor<Recipe>())
            
            for sharedGroupRecord in sharedGroups {
                
                let share: CKShare = try await cloudContainer.sharedCloudDatabase.record(for: sharedGroupRecord.share!.recordID) as! CKShare
                
                let currentUserId = share.currentUserParticipant?.participantID
                
                // Find other share participants
                let shareParticipants: [ShareParticipant] = share.participants.filter{$0.participantID != currentUserId ?? nil}.compactMap{ participant in
                    let nameComponents = participant.userIdentity.nameComponents
                    
                    if let nameComponents = nameComponents {
                        return ShareParticipant(firstName: nameComponents.givenName ?? "", lastName: nameComponents.familyName ?? "")
                    } else {
                        return nil
                    }
                }
                
                // Update local groups' recipes to match incoming shared groups
                let id = UUID(uuidString: sharedGroupRecord["CD_id"] as! String)
                
                if let matchingLocalGroup = localGroups.first(where: {$0.id == id}) {
                    let decoder = JSONDecoder()
                    if let encodedData = sharedGroupRecord["CD_encodedRecipes"] as? Data {
                        let incomingSharedRecipes = try decoder.decode([Recipe].self, from: encodedData)

                        // Add new recipes to existing shared group that aren't already stored locally
                        let newRecipes = incomingSharedRecipes.filter { sharedRecipe in
                            return localRecipes.contains(where: { $0.id == sharedRecipe.id }) == false
                        }
                        matchingLocalGroup.recipes!.append(contentsOf: newRecipes)
                        
                        // Remove recipes from matching local group that have been removed from the shared group. (They stay locally, they're just not part of the group anymore)
                        matchingLocalGroup.recipes!.removeAll(where: { localRecipe in
                            return incomingSharedRecipes.contains(where: {$0.id == localRecipe.id}) == false
                        })
                        
                        // Update share participants
                        matchingLocalGroup.shareParticipants = shareParticipants
                    }
                } else {
                    // Add new shared groups
                    let newGroup = RecipeGroup(from: sharedGroupRecord)
                    newGroup.shareParticipants = shareParticipants
                    
                    localContainer!.mainContext.insert(newGroup)
                }
            }
            
            try localContainer!.mainContext.save()
            
        } catch {
            print("Error fetching shared recipes.")
        }
    }
    
    private func fetchShares(scope: CKDatabase.Scope) async throws -> [CKRecord] {
        var groups: [CKRecord] = []
        
        let zones = try await cloudContainer.database(with: scope).allRecordZones()
        
        for zone in zones {
            let groupResults = try await cloudContainer.database(with: scope).records(matching: CKQuery(recordType: "CD_RecipeGroup", predicate: NSPredicate(value: true)), inZoneWith: zone.zoneID).matchResults
            
            let groupsInZone = try groupResults.map {
                let (_, record) = $0
                return try record.get()
            }
            
            groups.append(contentsOf: groupsInZone)
        }
        
        return groups
    }
    
    private func fetchGroupRecords(scope: CKDatabase.Scope) async throws -> [CKRecord] {
        var groups: [CKRecord] = []
        
        let zones = try await cloudContainer.database(with: scope).allRecordZones()
        
        for zone in zones {
            let groupResults = try await cloudContainer.database(with: scope).records(matching: CKQuery(recordType: "CD_RecipeGroup", predicate: NSPredicate(value: true)), inZoneWith: zone.zoneID).matchResults
            
            let groupsInZone = try groupResults.map {
                let (_, record) = $0
                return try record.get()
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
