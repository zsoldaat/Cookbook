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
class RecipeGroup: Identifiable, Hashable, ObservableObject {
    var id = UUID()
    var name: String = ""
    @Relationship(deleteRule: .nullify, inverse: \Recipe.group) var recipes: [Recipe]? = []
    
    init(name: String) {
        self.name = name
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
    
}
