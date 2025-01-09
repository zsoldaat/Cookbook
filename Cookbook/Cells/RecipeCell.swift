//
//  RecipeCell.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI



struct RecipeCell: View {
    
    let recipe: Recipe
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    let imageSize: CGFloat = 75
    
    var body: some View {
        
        HStack(alignment: .center) {
            AsyncImage(url: recipe.imageUrl) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageSize, height: imageSize, alignment: .center)
                    .clipped()
            } placeholder: {
                Color.gray.frame(width: imageSize, height: imageSize)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading) {
                Text(recipe.name).font(.headline)
                if let timeCommitment = recipe.timeCommitment {
                    Text(timeCommitment).lineLimit(1).font(.subheadline).foregroundStyle(.secondary, .secondary)
                }
                if let lastMadeDate = recipe.lastMadeDate {
                    Text("Last made: \(dateFormatter.string(from: lastMadeDate))").lineLimit(1).font(.subheadline).foregroundStyle(.secondary, .secondary)
                }
                
//                Text(recipe.instructions)
            }
            
        }
    }
}

//#Preview {
//    RecipeCell(recipe: Recipe(name: "Hello", instructions: "Instructions", ingredients: [Ingredient(name: "Tomato", quantityWhole: 1, quantityFraction: 0.5, unit: "item")]))
//}
