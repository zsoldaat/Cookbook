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
    
    @Environment(\.colorScheme) var colorScheme
    
    let recipe: Recipe
    @Binding var ratings: [Rating]
    
    init(recipe: Recipe) {
        self.recipe = recipe
        _ratings = .constant(["🤕", "☹️", "😐", "🙂", "😍"].map { value in
            return Rating(rating: value, opacity: recipe.rating == value ? 1 : 0)
        })
    }
    
    var body: some View {
        
        CardView(title: "Rating") {
            HStack {
                Spacer()
                ForEach(["🤕", "☹️", "😐", "🙂", "😍"], id:\.self) {rating in
                    if let image = rating.emojiToImage() {
                        Button {
                            recipe.rating = rating
                        } label: {
                            ZStack {
                                if (recipe.rating == rating) {
                                    Circle()
                                        .fill(colorScheme == .dark ? Color.white : Color.black)
                                }
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                    
                            }
                            .frame(width: 50, height: 50)
                            
                        }
                        .sensoryFeedback(trigger: recipe.rating == rating) { oldValue, newValue in
                            return SensoryFeedback.selection
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

//#Preview {
//    RatingView()
//}
