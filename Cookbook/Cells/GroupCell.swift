//
//  GroupCell.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-02-17.
//

import SwiftUI
import SwiftData

struct GroupCell: View {
    let group: RecipeGroup
    
    let imageSize: CGFloat = 90

    var body: some View {
        
        HStack(spacing: 10) {
            AsyncImage(url: group.recipes!.first?.imageUrl) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageSize, height: imageSize, alignment: .center)
                    .clipped()
            } placeholder: {
                Color.gray.frame(width: imageSize, height: imageSize)
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading) {
                Text(group.name).font(.headline)
                
//                if let lastMadeDate = recipe.lastMadeDate {
//                    Text("Last made on \(Recipe.dateFormatter.string(from: lastMadeDate))").lineLimit(1).font(.subheadline).foregroundStyle(.secondary, .secondary)
//                } else {
//                    Text("Added \(Recipe.dateFormatter.string(from: recipe.date))").lineLimit(1).font(.subheadline).foregroundStyle(.secondary, .secondary)
//                }
                
                HStack {
                    if (group.isShared) {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(.accent)
                    }
                }
            }
        }
    }
}
