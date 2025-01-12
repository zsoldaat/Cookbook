//
//  Unit.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-11.
//

enum Unit: String, Codable, Identifiable, CaseIterable {
    var id: Self { self }
    
    case item, cup, quart, tsp, tbsp, mL, L, oz, lb, g, kg, pinch, can
    
    private func getConversions() -> [Unit: Double] {
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
    
    func possibleConversions() -> [Unit] {
        return Array(self.getConversions().keys)
    }
    
    func conversion(to unit: Unit, quantity: Double) -> Double {
        let conversions = self.getConversions()
        if (conversions.keys.contains(unit)) {
            return conversions[unit]! * quantity
        } else {
            return quantity
        }
    }
    
    static func unconvertibleUnits() -> [Unit] {
        return [.item, .pinch, .can]
    }
}
