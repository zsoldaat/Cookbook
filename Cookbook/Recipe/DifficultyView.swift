//
//  DifficultyView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-02-17.
//

import SwiftUI

struct DifficultyView: View {
    
    let recipe: Recipe
    
    var body: some View {
        CardView(title: "Difficulty") {
            HStack {
                Spacer()
                ForEach(["Easy", "Medium", "Hard"], id: \.self) { difficulty in
                    DiffultyItem(difficulty: difficulty, isSelected: recipe.difficulty == difficulty, onSelect: {recipe.difficulty = $0})
                        .padding(.horizontal)
                }
                Spacer()
            }
        }
    }
}

struct DiffultyItem: View {
    
    let difficulty: String
    let isSelected: Bool
    let onSelect: (String) -> Void
    @State var opacity: Double = 0
    
    func emojiForDifficulty(_ difficulty: String) -> String {
        switch difficulty {
        case "Easy":
            return "🔴"
        case "Medium":
            return "🟡"
        case "Hard":
            return "🟢"
        default:
            return " "
        }
    }
    
    var body: some View {
        if let image = emojiForDifficulty(difficulty).emojiToImage() {
            Button {
                onSelect(difficulty)
            } label: {
                ZStack {
                    Circle()
                        .fill(.gray)
                        .opacity(opacity)
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        
                }
                .frame(width: 50, height: 50)
                .onAppear {
                    opacity = isSelected ? 1 : 0
                }
                .onChange(of: isSelected) { oldValue, newValue in
                    withAnimation {
                        opacity = newValue ? 1 : 0
                    }
                }
                .sensoryFeedback(.selection, trigger: isSelected)
            }
        }
    }
}
