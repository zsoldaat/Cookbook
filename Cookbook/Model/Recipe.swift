//
//  Recipe.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import Foundation
import SwiftData

@Model
class Recipe: Identifiable, Hashable, ObservableObject {
    @Attribute(.unique) var id = UUID()
    var date = Date()
    var name: String
    var instructions: String
    var ingredients: [Ingredient]
    var link: String?
    var imageUrl: URL?
    var timeCommitment: String?
    
    init(name: String, instructions: String, ingredients: [Ingredient]) {
        self.name = name
        self.instructions = instructions
        self.ingredients = ingredients
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
    
}
