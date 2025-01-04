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
        items.append(Ingredient(name: ingredient.name, quantityWhole: ingredient.quantityWhole, quantityFractionString: ingredient.quantityFractionString, unit: ingredient.unit))
    }
    
    func clear() {
        items.removeAll()
        selections.removeAll()
    }
}
