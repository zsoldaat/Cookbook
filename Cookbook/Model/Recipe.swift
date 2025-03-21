//
//  Recipe.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import Foundation
import SwiftData
import CloudKit

struct Tag: Hashable, Codable, Identifiable {
    var id = UUID()
    var name: String
}

@Model
final class Recipe: Identifiable, Hashable, ObservableObject, Codable {
    var id = UUID()
    var date = Date()
    var groups: [RecipeGroup]? = []
    var name: String = ""
    var instructions: String = ""
    @Relationship(deleteRule: .cascade, inverse: \Ingredient.recipe)
    var ingredients: [Ingredient]? = []
    var link: String?
    var imageUrl: URL?
    var difficulty: Float?
    var notes: String?
    var tags: [Tag]? = []
    var lastMadeDate: Date?
    var isShared: Bool { groups!.map {$0.isShared}.contains(true) }
    
    init(name: String, instructions: String, ingredients: [Ingredient]) {
        self.name = name
        self.instructions = instructions
        self.ingredients = ingredients
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
        case id, date, name, instructions, ingredients, link, imageUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        name = try container.decode(String.self, forKey: .name)
        instructions = try container.decode(String.self, forKey: .instructions)
        ingredients = try container.decode([Ingredient]?.self, forKey: .ingredients)
        link = try container.decode(String?.self, forKey: .link)
        imageUrl = try container.decode(URL?.self, forKey: .imageUrl)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(name, forKey: .name)
        try container.encode(instructions, forKey: .instructions)
        try container.encode(ingredients, forKey: .ingredients)
        try container.encode(link, forKey: .link)
        try container.encode(imageUrl, forKey: .imageUrl)
    }
}


