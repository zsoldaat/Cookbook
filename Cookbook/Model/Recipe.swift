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
    
    var id = UUID()
    var date = Date()
    var groups: [RecipeGroup]? = []
    var name: String = ""
    var instructions: String = ""
    @Relationship(deleteRule: .cascade, inverse: \Ingredient.recipe)
    var ingredients: [Ingredient]? = []
    var ingredientStrings: [String]?
    var link: String?
    var imageUrl: URL?
    var difficulty: String?
    var lastMadeDate: Date?
    var rating: Rating?
    var isShared: Bool { groups!.map {$0.isShared}.contains(true) }
    
    init(name: String, instructions: String, ingredients: [Ingredient], ingredientStrings: [String]? = nil) {
        self.name = name
        self.instructions = instructions
        self.ingredients = ingredients
        self.ingredientStrings = ingredientStrings
    }
    
    func save(context: ModelContext) {
        if context.hasChanges {
            if (self.isShared) {
                print("shared")
            } else {
                do {
                    try context.save()
                } catch (let error) {
                    print(error)
                }
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
    
    // Almost certainly won't need this anymore since switching to method of encoding ingredients and recipes
    
    init(from record: CKRecord, ingredients: [Ingredient]? = nil) {
        self.id = UUID(uuidString: record["CD_id"] as! String)!
        self.date = record["CD_date"] as! Date
        self.name = record["CD_name"] as! String
        self.instructions = record["CD_instructions"] as! String
        self.ingredients = ingredients
        self.ingredientStrings = record["CD_ingredientStrings"] as? [String]
        self.link = record["CD_link"] as? String
        if let imageUrl = record["CD_imageUrl"] {
            self.imageUrl = URL(string: imageUrl as! String)
        }
        self.difficulty = record["CD_difficulty"] as? String
        self.lastMadeDate = record["CD_lastMadeDate"] as? Date
//        self.rating = Rating(rawValue: ratingString)
    }
    
    //Codable conformance
    
    enum CodingKeys: CodingKey {
        case id, date, name, instructions, ingredients, ingredientStrings, link, imageUrl, difficulty, lastMadeDate, rating, ratingString, isShared
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        name = try container.decode(String.self, forKey: .name)
        instructions = try container.decode(String.self, forKey: .instructions)
        ingredients = try container.decode([Ingredient]?.self, forKey: .ingredients)
        ingredientStrings = try container.decode([String]?.self, forKey: .ingredientStrings)
        link = try container.decode(String?.self, forKey: .link)
        imageUrl = try container.decode(URL?.self, forKey: .imageUrl)
        difficulty = try container.decode(String?.self, forKey: .difficulty)
        lastMadeDate = try container.decode(Date?.self, forKey: .lastMadeDate)
        rating = try container.decode(Rating?.self, forKey: .rating)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
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
}


