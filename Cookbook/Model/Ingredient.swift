//
//  Ingredient.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import Foundation
import SwiftData

enum Unit: String, Codable, Identifiable {
    var id: Self { self }
    
    case item, cup, quart, tsp, tbsp, mL, L, oz, lb, g, kg, pinch
    
    func getConversions() -> [Unit: Double] {
        switch self {
        case .item:
            return [.item: 1]
        case .cup:
            return [.cup: 1, .mL: 240, .L: 0.24, .tsp: 48, .tbsp: 16, .quart: 0.25, .oz: 8]
        case .quart:
            return [.quart: 1, .cup: 4, .tsp: 192, .tbsp: 64, .mL: 960, .L: 0.96, .oz: 32]
        case .tsp:
            return [.tsp: 1, .cup: 0.02, .quart: 0.005, .tbsp: 0.33, .mL: 5, .L: 0.005, .oz: 0.166]
        case .tbsp:
            return [.tbsp: 1, .cup: 0.0625, .quart: 0.015, .tsp: 3, .mL: 15, .L: 0.015, .oz: 0.5]
        case .mL:
            return [.mL: 1, .cup: 0.04, .quart: 0.001, .tsp: 0.2, .tbsp: 0.067, .L: 0.001, .oz: 0.033]
        case .L:
            return [.L: 1, .cup: 4.22, .quart: 1.05, .tsp: 202.88, .tbsp: 67.6, .mL: 1000, .oz: 33.8 ]
        case .oz:
            return [.oz: 1, .cup: 0.125, .quart: 0.03, .tsp: 6, .tbsp: 2, .mL: 29.57, .L: 0.03, .lb: 0.0625, .g: 28.34, .kg: 0.0283 ]
        case .lb:
            return [.lb: 1, .oz: 16, .g: 453.59, .kg: 0.453 ]
        case .g:
            return [ .g: 1, .oz: 0.0353, .lb: 0.0022, .kg: 0.001, .mL: 1 ]
        case .kg:
            return [ .kg: 1, .oz: 35.274, .lb: 2.204, .g: 1000]
        default:
            return [self: 1]
        }
    }
    
    func conversion(to unit: Unit) -> Double {
        let conversions = self.getConversions()
        if (conversions.keys.contains(unit)) {
            return conversions[unit]!
        } else {
            return 1
        }
    }
}

@Model
class Ingredient: Identifiable, Hashable, ObservableObject {
    @Attribute(.unique) var id = UUID()
    var name: String
    var recipe: Recipe?
    var quantityWhole: Int
    var quantityFraction: Double
    var quantity: Double {Double(quantityWhole) + quantityFraction}
    var unit: Unit
    var index: Int
    
    init(name: String, recipe: Recipe? = nil, quantityWhole: Int, quantityFraction: Double, unit: Unit, index: Int) {
        self.name = name
        if let recipe = recipe {
            self.recipe = recipe
        }
        self.quantityWhole = quantityWhole
        self.quantityFraction = quantityFraction
        self.unit = unit
        self.index = index
    }
    
    //this code just cycles through the available conversion units for a given unit
    func changeDisplayUnit(displayUnit: Unit) -> Unit {
        
        let conversionInfo = unit.getConversions()
        
        let units: [Unit] = Array(conversionInfo.keys).sorted { $0.rawValue < $1.rawValue }
        
        if (units.last == displayUnit) {
            return units.first!
        }
        
        let currentIndex = units.firstIndex(of: displayUnit)
        return units[currentIndex! + 1]
    }
    
    func getString(displayUnit: Unit, scaleFactor: Int) -> String {
        
        let quantityString = getQuantityString(displayUnit: displayUnit, scaleFactor: scaleFactor)
        let unitString = getUnitString(displayUnit: displayUnit)
        
        if displayUnit == .item && quantityString == "1" {
            return ""
        }
        
        return "\(quantityString) \(unitString)"
    }
    
    private func getUnitString(displayUnit: Unit) -> String {
        
        let realUnit = unit == displayUnit ? unit : displayUnit
        
        switch realUnit {
        case .item:
            return ""
        default:
            return realUnit.rawValue
        }
    }
    
    private func getQuantity(displayUnit: Unit, scaleFactor: Int) -> Double {
        
        if (unit == displayUnit) {return quantity * Double(scaleFactor)}
        
        return quantity * unit.conversion(to: displayUnit) * Double(scaleFactor)
    }
    
    private func getQuantityString(displayUnit: Unit, scaleFactor: Int) -> String {
        
        let realQuantity = getQuantity(displayUnit: displayUnit, scaleFactor: scaleFactor)
        
        let quantityIsWhole = realQuantity.isNaN || realQuantity.isFinite && realQuantity.rounded() == realQuantity
        
        if (quantityIsWhole) {
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
    
}
