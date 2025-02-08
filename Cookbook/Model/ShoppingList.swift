//
//  ShoppingList.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-04.
//

import Foundation
import SwiftData
import CloudKit

@Model
class ShoppingList: Identifiable, Hashable, ObservableObject {
    var id = UUID()
    @Relationship(deleteRule: .cascade, inverse: \Ingredient.shoppingList) var items: [Ingredient]? = []
    @Transient var selections = Set<UUID>()
    
    init() {
        
    }
    
    init(from record: CKRecord, items: [Ingredient]? = nil) {
        self.id = UUID(uuidString: record["CD_id"] as! String)!
        self.items = items
        self.selections = Set<UUID>()
    }
    
    func addItem(_ ingredient: Ingredient) {
        if let existingItem = items!.first(where: { $0.name == ingredient.name && $0.unit.possibleConversions().contains(ingredient.unit) }) {
            addIngredients(existingIngredient: existingItem, newIngredient: ingredient)
        } else {
            items!.append(Ingredient(name: ingredient.name, quantityWhole: ingredient.quantityWhole, quantityFraction: ingredient.quantityFraction, unit: ingredient.unit, index: getNextIngredientIndex()))
        }
    }
    
    func getItems() -> [Ingredient] {
        return items!
    }
    
    func removeById(ids: [UUID]) {
        items!.removeAll { ingredient in
            ids.map{$0.uuidString}.contains(ingredient.id.uuidString)
        }
    }
    
    func deleteItem(indexSet: IndexSet, context: ModelContext) {
        for i in indexSet {
            context.delete(items![i])
        }
        do {
            try context.save()
        } catch {
            print("error")
        }
    }
    
    func clear() {
        items!.removeAll()
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
        
        if (existingIngredient.unit.possibleConversions().contains(newIngredient.unit)) {
            let convertedQuantity =  newIngredient.unit.conversion(to: existingIngredient.unit, quantity: newIngredient.quantity)
            let totalQuantity = existingIngredient.quantity + convertedQuantity
            
            existingIngredient.quantityWhole = Int(totalQuantity.rounded(.down))
            existingIngredient.quantityFraction = totalQuantity - totalQuantity.rounded(.down)
            
            return
        }
        
        print("\(newIngredient.unit.rawValue) cannot be converter to \(existingIngredient.unit.rawValue)")
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
    
    func getNextIngredientIndex() -> Int {
        return (items!.map { $0.index }.max() ?? 0) + 1
    }
    
}
