//
//  DifficultyView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-02-17.
//

import SwiftUI

struct DifficultyView: View {
    
    let recipe: Recipe
    
    @State var test = 0.0
    
    var body: some View {
        CardView(title: "Difficulty") {
            
            let difficultyBinding = Binding<Float>(get: {
                recipe.difficulty ?? 0
            }, set: {
                recipe.difficulty = $0
            })
            
            GradientSlider(value: difficultyBinding)
        }
    }
}
