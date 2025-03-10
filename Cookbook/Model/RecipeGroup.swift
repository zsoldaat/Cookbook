//
//  Group.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-02-08.
//


import Foundation
import SwiftData
import CloudKit

struct ShareParticipant: Codable {
    let firstName: String
    let lastName: String
}

@Model
final class RecipeGroup: Identifiable, Hashable, ObservableObject, Codable {
    var id = UUID()
    var name: String = ""
    @Relationship(deleteRule: .nullify, inverse: \Recipe.groups) var recipes: [Recipe]? = []
    var encodedRecipes: Data?
    var isShared: Bool = false
    var shareParticipants: [ShareParticipant] = []
    
    init(name: String) {
        self.name = name
    }
    
    init(from record: CKRecord) {
        self.id = UUID(uuidString: record["CD_id"] as! String)!
        self.name = record["CD_name"] as! String
        let decoder = JSONDecoder()
        do {
            if let encodedData = record["CD_encodedRecipes"] {
                let data = encodedData as! Data
                let recipes = try decoder.decode([Recipe].self, from: data)
                self.recipes = recipes
            }
        } catch {
            print(error)
            self.recipes = []
        }
        self.isShared = true
    }
    
    func addRecipe(recipe: Recipe) {
        if (recipes!.map{$0.id}.contains(recipe.id)) {
            print("This recipe has already been added")
            return
        }
        
        self.recipes!.append(recipe)

        encodeRecipes()
    }
    
    func removeRecipe(recipe: Recipe) {
        recipes = recipes!.filter{$0.id != recipe.id}
        encodeRecipes()
    }
    
    func encodeRecipes() {
        let jsonEncoder = JSONEncoder()
        let encoded = try! jsonEncoder.encode(recipes!)
        self.encodedRecipes = Data(encoded)
    }
    
    // Codable conformance
    
    enum CodingKeys: CodingKey {
        case id, name, encodedRecipes, isShared
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
//        recipes = try container.decode([Recipe].self, forKey: .recipes)
        encodedRecipes = try container.decode(Data.self, forKey: .encodedRecipes)
        isShared = try container.decode(Bool.self, forKey: .isShared)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
//        try container.encode(recipes, forKey: .recipes)
        try container.encode(encodedRecipes, forKey: .encodedRecipes)
        try container.encode(isShared, forKey: .isShared)
    }
    
}
