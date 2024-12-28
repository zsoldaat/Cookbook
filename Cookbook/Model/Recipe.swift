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
    var id = UUID()
    var date = Date()
    var name: String
    var instructions: String
    var ingredients: [Ingredient]
    
    init(name: String, instructions: String, ingredients: [Ingredient]) {
        self.name = name
        self.instructions = instructions
        self.ingredients = ingredients
    }
    
    func createUpdateRecipe(context: ModelContext) {
        context.insert(self)
        if context.hasChanges {
            do {
                try context.save()
            } catch (let error) {
                print(error)
            }
        }
    }
    
    func deleteRecipe(context: ModelContext) {
        
    }
    
}
