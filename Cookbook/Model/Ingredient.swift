//
//  Ingredient.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import Foundation
import SwiftData

var unitConversions: Dictionary<String, Dictionary<String, Double>> = [
    "cup": [
        "ml": 240,
        "l": 0.24,
        "tsp": 48,
        "tbsp": 16,
        "quart": 0.25,
        "oz": 8,
    ],
    "quart": [
        "cup": 4,
        "tsp": 192,
        "tbsp": 64,
        "ml": 960,
        "l": 0.96,
        "oz": 32
    ],
    "tsp": [
        "cup": 0.02,
        "quart": 0.005,
        "tbsp": 0.33,
        "ml": 5,
        "l": 0.005,
        "oz": 0.166,
    ],
    "tbsp": [
        "cup": 0.0625,
        "quart": 0.015,
        "tsp": 3,
        "ml": 14.7,
        "l": 0.015,
        "oz": 0.5
    ],
    "ml": [
        "cup": 0.004,
        "quart": 0.001,
        "tsp": 0.2,
        "tbsp": 0.067,
        "l": 0.001,
        "oz": 0.033,
    ],
    "l": [
        "cup": 4.22,
        "quart": 1.05,
        "tsp": 202.88,
        "tbsp": 67.6,
        "ml": 1000,
        "oz": 33.8,
    ],
    "oz": [
        "cup": 0.125,
        "quart": 0.03,
        "tsp": 6,
        "tbsp": 2,
        "ml": 29.57,
        "l": 0.03,
        "lb": 0.0625,
        "g": 28.34,
        "kg": 0.0283
    ],
    "lb": [
        "oz": 16,
        "g": 453.59,
        "kg": 0.453
    ],
    "g": [
        "oz": 0.0353,
        "lb": 0.0022,
        "kg": 0.001,
        "ml": 1,
    ],
    "kg": [
        "oz": 35.274,
        "lb": 2.204,
        "g": 1000,
        
    ]
]



@Model
class Ingredient: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var quantity: Double
    var unit: String
    var displayUnit: String
    
    init( name: String, quantity: Double, unit: String) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.displayUnit = unit
    }
    
    func getString() -> String {
        return "\(getQuantityString()) \(getUnitString())"
        //        return "\(getQuantityString()) \(getUnitString()) - \(quantity)"
    }
    
    //this code just cycles through the available conversion units for a given unit
    func changeDisplayUnit() {
        guard let conversionInfo: Dictionary<String, Double> = unitConversions[unit] else {return}
        let units: [String] = Array(conversionInfo.keys)
    
        if (unit == displayUnit) {
            displayUnit = units.first!
            return
        }
        
        if (units.last == displayUnit) {
            displayUnit = unit
            return
        }
        
        let currentIndex = units.firstIndex(of: displayUnit)
        displayUnit = units[currentIndex! + 1]
    }
    
    func getQuantityString() -> String {
        
        let realQuantity = unit == displayUnit ? quantity : quantity * unitConversions[unit]![displayUnit]!
        
        if (getQuantityWhole(quantity: realQuantity) == 0) {return getQuantityFractionString(quantity: realQuantity)}
        if (getQuantityFractionString(quantity: realQuantity).isEmpty) {return String(getQuantityWhole(quantity: realQuantity))}
        
        return "\(getQuantityWhole(quantity: realQuantity)) \(getQuantityFractionString(quantity: realQuantity))"
    }
    
    func getUnitString() -> String {
        
        let realUnit = unit == displayUnit ? unit : displayUnit
        
        switch realUnit {
        case "items":
            return "item"
        default:
            return realUnit
        }
    }
    
    //Find quantity value before decimal
    func getQuantityWhole(quantity: Double) -> Int {
        let whole = quantity.rounded(.down)
        if (whole > 0) {return Int(whole)}
        
        return 0
    }
    
    //Turn quantity value after decimal into fraction
    func getQuantityFractionString(quantity: Double) -> String {
        
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
