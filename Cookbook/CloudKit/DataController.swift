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
    
    let localContainer: ModelContainer = {
        let schema = Schema([Recipe.self, ShoppingList.self])
        let container = try! ModelContainer(for: schema, configurations: [])
        
        let listCount = try! container.mainContext.fetchCount(FetchDescriptor<ShoppingList>())
        if listCount == 0 {
            container.mainContext.insert(ShoppingList())
        }
//                container.deleteAllData()
        return container
    }()
    
    static var containerIdentifier: String = "iCloud.com.zacsoldaat.Cookbook"
    
    var cloudContainer = CKContainer(identifier: DataController.containerIdentifier)
    /// Sharing requires using a custom record zone.
//    var recordZone = CKRecordZone(zoneName: "com.apple.coredata.cloudkit.zone")
    
//    var sharedRecipes: [Recipe] = []
    
//    func setSharedRecipes() async {
//        do {
//            let recipes = try await fetchRecipes(scope: .shared)
//            sharedRecipes.append(contentsOf: recipes)
//        } catch {
//            print(error)
//        }
//    }
    
    func fetchRecipes(scope: CKDatabase.Scope) async throws -> [Recipe] {
        
        var recipes: [Recipe] = []
        
        let zones = try await cloudContainer.database(with: scope).allRecordZones()
        
        for zone in zones {
            let recipeResults = try await cloudContainer.database(with: scope).records(matching: CKQuery(recordType: "CD_Recipe", predicate: NSPredicate(value: true)), inZoneWith: zone.zoneID).matchResults
            let ingredientResults = try await cloudContainer.database(with: scope).records(matching: CKQuery(recordType: "CD_Ingredient", predicate: NSPredicate(value: true)), inZoneWith: zone.zoneID).matchResults
            
            let recipesInZone = try recipeResults.map {
                let (_, record) = $0
                
                let ingredients = try ingredientResults
                    .filter { (_, ingredientRecord) in
                        let ingredientRecipeId = try! ingredientRecord.get()["CD_recipe"] as! String
                        let recordName = try record.get().recordID.recordName
                        
                        return ingredientRecipeId == recordName
                    }.map { (_, ingredientRecord) in
                        return Ingredient(from: try ingredientRecord.get())
                    }
                
                return Recipe(from: try record.get(), ingredients: ingredients)
            }
            
            recipes.append(contentsOf: recipesInZone)
        }
        
        recipes.forEach { recipe in
            localContainer.mainContext.insert(recipe)
        }
        
        try localContainer.mainContext.save()
        
        return recipes
    }
    
    func fetchRecord(recipe: Recipe, scope: CKDatabase.Scope) async throws -> CKRecord? {
        let zones = try await cloudContainer.database(with: scope).allRecordZones()
        
        for zone in zones {
            if let result = try! await cloudContainer.database(with: scope).records(matching: CKQuery(recordType: "CD_Recipe", predicate: NSPredicate(format: "CD_id == %@", recipe.id.uuidString)), inZoneWith: zone.zoneID).matchResults.first {
                
                let (recordId, record) = result
                
                do {
                    let record = try record.get()
                    
                    //Set parent relationships whenever you fetch
                    let ingredients = try! await cloudContainer.database(with: scope).records(matching: CKQuery(recordType: "CD_Ingredient", predicate: NSPredicate(format: "CD_recipe == %@", record.recordID.recordName)), inZoneWith: zone.zoneID).matchResults
                    
                    for ingredient in ingredients {
                        let (_, record) = ingredient
                        let ingredientRecord = try record.get()
                        ingredientRecord.setParent(recordId)
                        try await cloudContainer.privateCloudDatabase.save(ingredientRecord)
                    }
                    
                    return record
                } catch {
                    print(error)
                    return nil
                }
            }
        }
        
        return nil
    }
    
    func fetchOrCreateShare(recipe: Recipe, scope: CKDatabase.Scope) async throws -> (CKShare, CKContainer)? {
        
        guard let associatedRecord = try await fetchRecord(recipe: recipe, scope: scope) else {return nil}
        
        guard let existingShare = associatedRecord.share else {
            let share = CKShare(rootRecord: associatedRecord)
            share[CKShare.SystemFieldKey.title] = "Recipe: \(recipe.name)"
            
            if let url = recipe.imageUrl {
                let imageData = try Data(contentsOf: url)
                share[CKShare.SystemFieldKey.thumbnailImageData] = imageData
            }
            
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
