//
//  RatingView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-16.
//

import SwiftUI

struct RatingView: View {
    
    let recipe: Recipe
    
    var body: some View {
        CardView(title: "Rating") {
            HStack {
                Spacer()
                ForEach(Rating.allCases.filter{$0 != .none}) { rating in
                    RatingItem(rating: rating, isSelected: recipe.rating == rating, onSelect: {recipe.rating = $0})
                }
                Spacer()
            }
        }
    }
}

struct RatingItem: View {
    
    let rating: Rating
    let isSelected: Bool
    let onSelect: (Rating) -> Void
    @State var opacity: Double = 0
    
    var body: some View {
        if let image = rating.image() {
            Button {
                onSelect(rating)
            } label: {
                ZStack {
                    Circle()
                        .fill(.gray)
                        .opacity(opacity)
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 40, height: 40)
                        
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



//#Preview {
//    RatingView()
//}
