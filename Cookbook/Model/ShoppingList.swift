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
            addIngredients(ingredient1: existingItem, ingredient2: ingredient)
        } else {
            items.append(Ingredient(name: ingredient.name, quantityWhole: ingredient.quantityWhole, quantityFractionString: ingredient.quantityFractionString, unit: ingredient.unit))
        }
        
        
    }
    
    func clear() {
        items.removeAll()
        selections.removeAll()
    }
    
    func addIngredients(ingredient1: Ingredient, ingredient2: Ingredient) {
        
        if (ingredient1.unit == ingredient2.unit) {
            let totalQuantity = ingredient1.quantity + ingredient2.quantity
            let wholePart = Int(totalQuantity.rounded(.down))
            let decimals = totalQuantity - totalQuantity.rounded(.down)
            print(totalQuantity, String(wholePart), ingredient1.decimalsRepresentedAsFraction(decimals: decimals))
            
            
        }
    }
    
}
