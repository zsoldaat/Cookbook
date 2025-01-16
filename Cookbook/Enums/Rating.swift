//
//  Rating.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-16.
//
import SwiftUI

enum Rating: String, Codable, CaseIterable, Identifiable {
    var id: Self { self }
    
    case none, worst, bad, medium, good, great
    
    func emoji() -> String {
        switch self {
        case .none: return " "
        case .worst: return "🤕"
        case .bad: return "☹️"
        case .medium: return "😐"
        case .good: return "😊"
        case .great: return "😄"
        }
    }
    
    func image() -> UIImage? {
        return self.emoji().emojiToImage()
    }
    
}
