//
//  Recipe.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import Foundation
import SwiftData
import CloudKit

@Model
final class Recipe: Identifiable, Hashable, ObservableObject, Codable {
    
    @Attribute var id = UUID()
    @Attribute var date = Date()
    @Attribute var name: String = ""
    @Attribute var instructions: String = ""
    @Relationship(deleteRule: .cascade, inverse: \Ingredient.recipe) var ingredients: [Ingredient]? = []
    @Attribute var group: String? = "Group 1"
    @Attribute var ingredientStrings: [String]?
    @Attribute var link: String?
    @Attribute var imageUrl: URL?
    @Attribute var difficulty: String?
    @Attribute var lastMadeDate: Date?
    @Attribute var rating: Rating?
    
    init(name: String, instructions: String, ingredients: [Ingredient], ingredientStrings: [String]? = nil) {
        self.name = name
        self.instructions = instructions
        self.ingredients = ingredients
        self.ingredientStrings = ingredientStrings
    }
    
    func save(context: ModelContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch (let error) {
                print(error)
            }
        }
    }
    
    func createUpdateRecipe(context: ModelContext) {
        context.insert(self)
        save(context: context)
    }
    
    func addImage(url: URL, context: ModelContext) {
        self.imageUrl = url
        save(context: context)
    }
    
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    func getNextIngredientIndex() -> Int {
        return (ingredients!.map { $0.index }.max() ?? 0) + 1
    }
    
    //Codable conformance
    
    enum CodingKeys: CodingKey {
        case id, date, name, instructions, ingredients, ingredientStrings, link, imageUrl, difficulty, lastMadeDate, rating
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        name = try container.decode(String.self, forKey: .name)
        instructions = try container.decode(String.self, forKey: .instructions)
        ingredients = try container.decode([Ingredient].self, forKey: .ingredients)
        ingredientStrings = try container.decode([String].self, forKey: .ingredientStrings)
        link = try container.decode(String.self, forKey: .link)
        imageUrl = try container.decode(URL.self, forKey: .imageUrl)
        difficulty = try container.decode(String.self, forKey: .difficulty)
        lastMadeDate = try container.decode(Date.self, forKey: .lastMadeDate)
        rating = try container.decode(Rating.self, forKey: .rating)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(instructions, forKey: .instructions)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(ingredientStrings, forKey: .ingredientStrings)
        try container.encode(link, forKey: .link)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(lastMadeDate, forKey: .lastMadeDate)
        try container.encode(rating, forKey: .rating)
    }
    
    //Cloudkit
    
    var asRecord: CKRecord {
        let record = CKRecord(
            recordType: "Recipe",
            recordID: .init(zoneID: CKRecordZone.ID(zoneName: self.group!, ownerName: CKCurrentUserDefaultName))
        )
        record[RecipeProperties.id.rawValue] = self.id.uuidString
        record[RecipeProperties.date.rawValue] = self.date
        record[RecipeProperties.name.rawValue] = self.name
        record[RecipeProperties.instructions.rawValue] = self.instructions
        return record
    }
    
    init?(from record: CKRecord) {
        guard
            let id = record[RecipeProperties.id.rawValue] as? String,
            let date = record[RecipeProperties.date.rawValue] as? Date,
            let name = record[RecipeProperties.name.rawValue] as? String,
            let instructions = record[RecipeProperties.instructions.rawValue] as? String
        else { return nil }
        
        self.id = UUID(uuidString: id)!
        self.date = date
        self.ingredients = []
        self.name = name
        self.instructions = instructions
    }
}

private enum RecipeProperties: String, CodingKey {
    case id, date, name, instructions, ingredients, group, ingredientStrings, link, imageUrl, difficulty, lastMade, rating
}

final class CloudKitService {
    static let container = CKContainer(
        identifier: "iCloud.com.zacsoldaat.Cookbook"
    )
    
    func save(_ recipe: Recipe) async throws {
        _ = try await Self.container.privateCloudDatabase.modifyRecordZones(
            saving: [CKRecordZone(zoneName: recipe.group!)],
            deleting: []
        )
        _ = try await Self.container.privateCloudDatabase.modifyRecords(
            saving: [recipe.asRecord],
            deleting: []
        )
    }
}

extension CloudKitService {
    func shareRecipeRecords() async throws -> CKShare {
        _ = try await Self.container.privateCloudDatabase.modifyRecordZones(
            saving: [CKRecordZone(zoneName: "Group 1")],
            deleting: []
        )
        
        let share = CKShare(recordZoneID: CKRecordZone.ID(zoneName: "Group 1", ownerName: CKCurrentUserDefaultName))
        share.publicPermission = .readOnly
        let result = try await Self.container.privateCloudDatabase.save(share)
        return result as! CKShare
    }
}

extension CloudKitService {
    func accept(_ metadata: CKShare.Metadata) async throws {
        try await Self.container.accept(metadata)
    }
}




