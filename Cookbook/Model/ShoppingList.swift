//
//  ShoppingList.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-04.
//

//
//  Recipe.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import Foundation
import SwiftData

@Model
class ShoppingList: Identifiable, Hashable, ObservableObject {
    @Attribute(.unique) var id = UUID()
    private var items: [Ingredient] = []
    var selections = Set<UUID>()
    
    init() {
        
    }
    
    func getItems() -> [Ingredient] {
        return items
    }
    
    func addItem(_ ingredient: Ingredient) {
        
        if let existingItem = items.first(where: { $0.name == ingredient.name }) {
            addIngredients(existingIngredient: existingItem, newIngredient: ingredient)
        } else {
            items.append(Ingredient(name: ingredient.name, quantityWhole: ingredient.quantityWhole, quantityFraction: ingredient.quantityFraction, unit: ingredient.unit))
        }
    }
    
    func clear() {
        items.removeAll()
        selections.removeAll()
    }
    
    func addIngredients(existingIngredient: Ingredient, newIngredient: Ingredient) {
        
        if (existingIngredient.unit == newIngredient.unit) {
            let totalQuantity = existingIngredient.quantity + newIngredient.quantity
            let wholePart = Int(totalQuantity.rounded(.down))
            let decimals = totalQuantity - totalQuantity.rounded(.down)
            
            existingIngredient.quantityWhole = wholePart
            existingIngredient.quantityFraction = decimals
            
            return
        }
        
        print("Ingredients do not share the same unit")
    }
    
}
