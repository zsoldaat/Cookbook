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
final class ShoppingList: Identifiable, Hashable, ObservableObject, Codable {
    var id = UUID()
    @Relationship(deleteRule: .cascade, inverse: \Ingredient.shoppingList) var items: [Ingredient]? = []
    var selections = Set<UUID>()
    
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
    
    func deleteItem(item: Ingredient) {
        items?.removeAll{$0.id == item.id}
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
    
    // Codable Conformance
    
    enum CodingKeys: CodingKey {
        case id, items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        items = try container.decode([Ingredient].self, forKey: .items)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(items, forKey: .items)
    }
    
}
