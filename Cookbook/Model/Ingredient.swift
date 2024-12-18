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
    
    func getString() -> String {
        return "\(getQuantityString()) \(unit)"
//        return "\(getQuantityString()) \(unit) - \(quantity)"
    }
    
    func getQuantityString() -> String {
        if (getQuantityWhole() == 0) {return getQuantityFractionString()}
        if (getQuantityFractionString().isEmpty) {return String(getQuantityWhole())}
        
        return "\(getQuantityWhole()) \(getQuantityFractionString())"
    }
    
    func getUnitString() -> String {
        switch unit {
        case "items":
            return "item"
        case "ml":
            return "ml"
        case "g":
            return "g"
        case "kg":
            return "kg"
        default:
            return unit
        }
    }
    
    //Find quantity value before decimal
    func getQuantityWhole() -> Int {
        let whole = quantity.rounded(.down)
        if (whole > 0) {return Int(whole)}
        
        return 0
    }
    
    //Turn quantity value after decimal into fraction
    func getQuantityFractionString() -> String {
        
        let isQuantityWhole = quantity.isNaN || quantity.isFinite && quantity.rounded() == quantity
        
        if (isQuantityWhole) {
            return ""
        }
        
        let decimalsOfDouble = String(quantity).split(separator: ".")[1...].joined()
        
        let double = Double("0.\(decimalsOfDouble)") ?? 0

        switch decimalsOfDouble.count {
        case 1:
            if (decimalsOfDouble == "5") { return "1/2"}
        case 2:
            if (decimalsOfDouble == "25") {return "1/4"}
            if (decimalsOfDouble == "33") {return "1/3"}
            if (decimalsOfDouble == "66") {return "2/3"}
            if (decimalsOfDouble == "67") {return "2/3"}
            if (decimalsOfDouble == "75") {return "3/4"}
            
        case 3...:
            if (decimalsOfDouble.prefix(2) == "33") {return "1/3"}
            if (decimalsOfDouble.prefix(2) == "66") {return "2/3"}
            
            if (double*8.rounded() == double*8) {
                return "\(String(Int(double*8)))/8"
            }
            
            if (double*4.rounded() == double*8) {
                return "\(String(Int(double*4)))/4"
            }
            
        default:
            return String(quantity)
        }
        
        return String(quantity)
        
    }
}
