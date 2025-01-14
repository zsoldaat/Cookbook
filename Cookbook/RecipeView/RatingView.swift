//
//  RatingView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-14.
//

import SwiftUI

class Rating: ObservableObject {
    let rating: String
    @Published var opacity: Double
    
    init(rating: String, opacity: Double) {
        self.rating = rating
        self.opacity = opacity
    }
}

struct RatingView: View {

    let recipe: Recipe
    let ratings: [Rating]
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.ratings = ["🤕", "☹️", "😐", "🙂", "😍"].map { value in
            return Rating(rating: value, opacity: recipe.rating == value ? 1 : 0)
        }
    }
    
    func onClick(rating: String) {
        recipe.rating = rating
    }
    
    var body: some View {
        
        CardView(title: "Rating") {
            HStack {
                Spacer()
                ForEach(["🤕", "☹️", "😐", "🙂", "😍"], id:\.self) {rating in
                    @ObservedObject var ratingObject = Rating(rating: rating, opacity: recipe.rating == rating ? 1 : 0)
                    RatingItem(rating: ratingObject.rating, opacity: $ratingObject.opacity, onClick: onClick)
                }
                Spacer()
            }
        }
    }
}

struct RatingItem: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let rating: String
    @Binding var opacity: Double
    let onClick: (String) -> Void

    var body: some View {
        if let image = rating.emojiToImage() {
            Button {
                onClick(rating)
            } label: {
                ZStack {
                    Circle()
                        .fill(colorScheme == .dark ? Color.white : Color.black)
                        .opacity(opacity)
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }
                .frame(width: 50, height: 50)
            }
            
        }
    }
}

//#Preview {
//    RatingView()
//}
