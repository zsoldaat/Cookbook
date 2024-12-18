//
//  Ingredient.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import Foundation
import SwiftData

@Model
class Ingredient: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var quantity: Double
    var unit: String
    
    init( name: String, quantity: Double, unit: String) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
}
