//
//  ShoppingList.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-18.
//

import Foundation

class ShoppingList: ObservableObject {
    @Published var items: [Ingredient] = []
    @Published var selections = Set<UUID>()
    
    func clear() {
        items.removeAll()
        selections.removeAll()
    }
}
