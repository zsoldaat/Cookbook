//
//  RecipeCell.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI
import SwiftData

struct RecipeCell: View {
    let recipe: Recipe
    
    let imageSize: CGFloat = 90
    
    var body: some View {
        
        HStack(spacing: 10) {
            AsyncImage(url: recipe.imageUrl) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageSize, height: imageSize, alignment: .center)
                    .clipped()
            } placeholder: {
                Color.gray.frame(width: imageSize, height: imageSize)
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading) {
                Text(recipe.name).font(.headline)

                if let lastMadeDate = recipe.lastMadeDate {
                    Text("Made on \(Recipe.dateFormatter.string(from: lastMadeDate))").lineLimit(1).font(.subheadline).foregroundStyle(.secondary, .secondary)
                } else {
                    Text("Added \(Recipe.dateFormatter.string(from: recipe.date))").lineLimit(1).font(.subheadline).foregroundStyle(.secondary, .secondary)
                }
                
                HStack {
                    if (recipe.isShared) {
                        Image(systemName: "person.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15)
                            .foregroundStyle(.accent)
                    }
                }
            }
        }
    }
}

//#Preview {
//    RecipeCell(recipe: Recipe(name: "Hello", instructions: "Instructions", ingredients: [Ingredient(name: "Tomato", quantityWhole: 1, quantityFraction: 0.5, unit: "item")]))
//}
