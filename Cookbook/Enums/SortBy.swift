//
//  SortBy.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-10-15.
//

enum SortBy: String, Codable, Identifiable, CaseIterable {
    var id: Self { self }
    
    case date, name, difficulty, lastMade
}
