//
//  Ingredient.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import Foundation
import SwiftData
import CoreTransferable
import UniformTypeIdentifiers
import CloudKit

@Model
final class Ingredient: Identifiable, Hashable, ObservableObject, Codable {
    
    var id = UUID()
    var name: String = ""
    var recipe: Recipe?
    var shoppingList: ShoppingList?
    var quantityWhole: Int = 0
    var quantityFraction: Double = 0
    var quantity: Double {Double(quantityWhole) + quantityFraction}
    var unit: Unit = Unit.item
    var index: Int = 0
    
    init(name: String, quantityWhole: Int, quantityFraction: Double, unit: Unit, index: Int) {
        self.name = name
        self.quantityWhole = quantityWhole
        self.quantityFraction = quantityFraction
        self.unit = unit
        self.index = index
    }
    
    func getUnitString(displayUnit: Unit) -> String {
        
        let realUnit = unit == displayUnit ? unit : displayUnit
        
        switch realUnit {
        case .item:
            return ""
        default:
            return realUnit.rawValue
        }
    }
    
    func getQuantityString(displayUnit: Unit, scaleFactor: Int) -> String {
        
        let realQuantity = getQuantity(displayUnit: displayUnit, scaleFactor: scaleFactor)
        
        let quantityIsWhole = realQuantity.isNaN || realQuantity.isFinite && realQuantity.rounded() == realQuantity
        
        if (quantityIsWhole) {
            
            if realQuantity.rounded() == 1 && displayUnit == .item {
                return ""
            }
            
            return String(Int(realQuantity))
        }
        
        let wholePart = Int(realQuantity.rounded(.down))
        let decimalPart = realQuantity - realQuantity.rounded(.down)
        
        guard let decimalsAsFraction = Ingredient.decimalsRepresentedAsFraction(decimals: decimalPart) else {
            //Just round the number to 4 places if it's not a nice fraction
            let roundedToFourDecimals = (realQuantity*10000).rounded() / 10000
            return String(roundedToFourDecimals)
        }
        
        if (wholePart == 0) {
            return decimalsAsFraction
        }
        
        return "\(String(wholePart)) \(decimalsAsFraction)"
        
    }
    
    func getString() -> String {
        
        var string: String = ""
        
        let quantityString = self.getQuantityString(displayUnit: unit, scaleFactor: 1)
        if (quantityString != "") {string += quantityString + " "}
        
        let unitString = self.getUnitString(displayUnit: unit)
        if (unitString != "") {string += unitString + " "}
        
        string += self.name
        
        return string
    }
    
    private func getQuantity(displayUnit: Unit, scaleFactor: Int) -> Double {
        
        if (unit == displayUnit) {return quantity * Double(scaleFactor)}
        
        return unit.conversion(to: displayUnit, quantity: quantity) * Double(scaleFactor)
    }
    
    //returns nil if the decimals cannot be cleanly represented as a string
    static func decimalsRepresentedAsFraction(decimals: Double) -> String? {
        
        let decimalString = String(decimals)
        
        var decimalsRepresentedAsFraction: String = ""
        
        switch decimalString.prefix(4) {
        case "0.25":
            decimalsRepresentedAsFraction = "1/4"
        case "0.33":
            decimalsRepresentedAsFraction = "1/3"
        case "0.5":
            decimalsRepresentedAsFraction = "1/2"
        case "0.66":
            decimalsRepresentedAsFraction = "2/3"
        case "0.75":
            decimalsRepresentedAsFraction = "3/4"
        default:
            
            if ((decimals*4).rounded() == decimals*4) {
                decimalsRepresentedAsFraction = "\(String(Int(decimals*4)))/4"
                break
            }
            
            if ((decimals*8).rounded() == decimals*8) {
                decimalsRepresentedAsFraction = "\(String(Int(decimals*8)))/8"
                break
            }
            
            decimalsRepresentedAsFraction = ""
        }
        
        if (decimalsRepresentedAsFraction.isEmpty) {
            return nil
        } else {
            return decimalsRepresentedAsFraction
        }
    }
    
    static func fractionToDouble(fraction: String) -> Double {
        if (fraction.isEmpty) {return Double(0)}
        
        let numerator = Double(String(fraction.first!))!
        let denominator = Double(String(fraction.last!))!
        
        return numerator/denominator
        
    }
    
    //Codable Conformance
    
    enum CodingKeys: CodingKey {
        case id, name, quantityWhole, quantityFraction, unitString, unit, index
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        quantityWhole = try container.decode(Int.self, forKey: .quantityWhole)
        quantityFraction = try container.decode(Double.self, forKey: .quantityFraction)
        unit = try container.decode(Unit.self, forKey: .unit)
        index = try container.decode(Int.self, forKey: .index)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(quantityWhole, forKey: .quantityWhole)
        try container.encode(quantityFraction, forKey: .quantityFraction)
        try container.encode(unit, forKey: .unit)
        try container.encode(index, forKey: .index)
    }
    
}
