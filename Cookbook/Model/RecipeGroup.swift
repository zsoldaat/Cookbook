//
//  Group.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-02-08.
//


import Foundation
import SwiftData
import CloudKit

@Model
final class RecipeGroup: Identifiable, Hashable, ObservableObject, Codable {
    var id = UUID()
    var name: String = ""
    @Relationship(deleteRule: .nullify, inverse: \Recipe.group) var recipes: [Recipe]? = []
    var isShared: Bool = false
    
    init(name: String) {
        self.name = name
    }
    
    init(from record: CKRecord, recipes: [Recipe]? = nil) {
        self.id = UUID(uuidString: record["CD_id"] as! String)!
        self.name = record["CD_name"] as! String
        self.recipes = recipes
        self.isShared = true
    }
    
    func addRecipe(recipe: Recipe) {
        
        if (recipes!.map{$0.id}.contains(recipe.id)) {
            print("This recipe has already been added")
            return
        }
        
        self.recipes!.append(recipe)
        
        //do cloudkit stuff
    }
    
    func removeRecipe(recipe: Recipe) {
        recipes = recipes!.filter{$0.id != recipe.id}
        
        // do cloudkit stuff
    }
    
    // Codable conformance
    
    enum CodingKeys: CodingKey {
        case id, name, isShared
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
//        recipes = try container.decode([Recipe].self, forKey: .recipes)
        isShared = try container.decode(Bool.self, forKey: .isShared)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
//        try container.encode(recipes, forKey: .recipes)
        try container.encode(isShared, forKey: .isShared)
    }
    
}
