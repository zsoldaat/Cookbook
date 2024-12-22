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
        "mL": 240,
        "L": 0.24,
        "tsp": 48,
        "tbsp": 16,
        "quart": 0.25,
        "oz": 8,
    ],
    "quart": [
        "cup": 4,
        "tsp": 192,
        "tbsp": 64,
        "mL": 960,
        "L": 0.96,
        "oz": 32
    ],
    "tsp": [
        "cup": 0.02,
        "quart": 0.005,
        "tbsp": 0.33,
        "mL": 5,
        "L": 0.005,
        "oz": 0.166,
    ],
    "tbsp": [
        "cup": 0.0625,
        "quart": 0.015,
        "tsp": 3,
        "mL": 14.7,
        "L": 0.015,
        "oz": 0.5
    ],
    "mL": [
        "cup": 0.004,
        "quart": 0.001,
        "tsp": 0.2,
        "tbsp": 0.067,
        "L": 0.001,
        "oz": 0.033,
    ],
    "L": [
        "cup": 4.22,
        "quart": 1.05,
        "tsp": 202.88,
        "tbsp": 67.6,
        "mL": 1000,
        "oz": 33.8,
    ],
    "oz": [
        "cup": 0.125,
        "quart": 0.03,
        "tsp": 6,
        "tbsp": 2,
        "mL": 29.57,
        "L": 0.03,
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
        "mL": 1,
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
    
    func resetDisplayUnit() {
        displayUnit = unit
    }
    
    private func getUnitString() -> String {
        
        let realUnit = unit == displayUnit ? unit : displayUnit
        
        switch realUnit {
        case "items":
            return "item"
        default:
            return realUnit
        }
    }
    
    private func getQuantityString() -> String {
        
        let realQuantity = unit == displayUnit ? quantity : quantity * unitConversions[unit]![displayUnit]!
        
        let quantityIsWhole = realQuantity.isNaN || realQuantity.isFinite && realQuantity.rounded() == realQuantity
        
        if (quantityIsWhole) {
            return String(Int(realQuantity))
        }
        
        let wholePart = Int(realQuantity.rounded(.down))
        let decimalPart = realQuantity - realQuantity.rounded(.down)
        
        guard let decimalsAsFraction = decimalsRepresentedAsFraction(decimals: decimalPart) else {
            let roundedToFourDecimals = (realQuantity*10000).rounded() / 10000
            return String(roundedToFourDecimals)
        }
        
        return "\(String(wholePart)) \(decimalsAsFraction)"
        
    }
    
    //returns nil if the decimals cannot be cleanly represented as a string
    private func decimalsRepresentedAsFraction(decimals: Double) -> String? {
        
        let decimalString = String(quantity - quantity.rounded(.down))
        
        var decimalsRepresentedAsFraction: String = ""
        
        switch decimalString.count {
        case 1:
            if (decimalString == "5") { decimalsRepresentedAsFraction = "1/2"}
        case 2:
            if (decimalString == "25") {decimalsRepresentedAsFraction = "1/4"}
            if (decimalString == "33") {decimalsRepresentedAsFraction = "1/3"}
            if (decimalString == "66") {decimalsRepresentedAsFraction = "2/3"}
            if (decimalString == "67") {decimalsRepresentedAsFraction = "2/3"}
            if (decimalString == "75") {decimalsRepresentedAsFraction = "3/4"}
            
        case 3...:
            if (decimalString.prefix(2) == "33") {decimalsRepresentedAsFraction = "1/3"}
            if (decimalString.prefix(2) == "66") {decimalsRepresentedAsFraction = "2/3"}
            
            if ((decimals*8).rounded() == decimals*8) {
                decimalsRepresentedAsFraction = "\(String(Int(decimals*8)))/8"
            }
            
            if ((decimals*4).rounded() == decimals*4) {
                decimalsRepresentedAsFraction = "\(String(Int(decimals*4)))/4"
            }
            
        default:
            decimalsRepresentedAsFraction = ""
        }
        
        if (decimalsRepresentedAsFraction.isEmpty) {
            return nil
        } else {
            return decimalsRepresentedAsFraction
        }
    }

}
