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
    
    func addItem(_ ingredient: Ingredient) {
        
        if let existingItem = items.first(where: { $0.name == ingredient.name }) {
            addIngredients(existingIngredient: existingItem, newIngredient: ingredient)
        } else {
            items.append(Ingredient(name: ingredient.name, quantityWhole: ingredient.quantityWhole, quantityFraction: ingredient.quantityFraction, unit: ingredient.unit))
        }
    }
    
    func getItems() -> [Ingredient] {
        return items
    }
    
    func deleteItem(indexSet: IndexSet, context: ModelContext) {
        for i in indexSet {
            context.delete(items[i])
        }
        do {
            try context.save()
        } catch {
            print("error")
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
    
    func save(context: ModelContext) {
        context.insert(self)
        if context.hasChanges {
            do {
                try context.save()
            } catch (let error) {
                print(error)
            }
        }
    }
    
}
