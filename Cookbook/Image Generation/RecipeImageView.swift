//
//  ImageGeneratorView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-06.
//

import SwiftUI

struct RecipeImageView: View {
    
    let recipe: Recipe
    
    @State var imageSelectShowing: Bool = false
    
    var body: some View {
        VStack {
            Button {
                imageSelectShowing = true
            } label: {
                Text("Generate an image for this recipe.")
            }
        }
        .sheet(isPresented: $imageSelectShowing) {
            ImageSelectView(query: recipe.name)
        }
    }
}

//#Preview {
//    ImageGeneratorView()
//}
