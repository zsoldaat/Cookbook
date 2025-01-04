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
    var items: [Ingredient] = []
    var selections = Set<UUID>()
    
    init() {
        
    }
    
    func clear() {
        items.removeAll()
        selections.removeAll()
    }
    
}
