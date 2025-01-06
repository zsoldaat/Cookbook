//
//  ImageGeneratorView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-06.
//

import SwiftUI

struct RecipeImageView: View {
    
    @Environment(\.modelContext) var context
    
    let recipe: Recipe
    
    @State var imageSelectShowing: Bool = false
    @State var alertShowing: Bool = false
    
    func onSelect(url: URL) -> Void {
        recipe.addImage(url: url, context: context)
    }
    
    var body: some View {
        VStack {
            if let imageUrl = recipe.imageUrl {
                AsyncImage(url: imageUrl) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .scaledToFit()
                .frame(width: 100)
                .onLongPressGesture {
                    alertShowing = true
                }
            } else {
                Button {
                    imageSelectShowing = true
                } label: {
                    Text("Generate Image")
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .frame(width: 100, height: 100)
                        .background(Rectangle().fill(Color.gray))
                }
            }
        }
        .sheet(isPresented: $imageSelectShowing) {
            ImageSelectView(query: recipe.name, onSelect: onSelect)
        }
        .alert(isPresented: $alertShowing) {
            Alert(
                title: Text("Generate a different image?"),
                primaryButton:
                        .default(Text("Yes"), action: {
                            imageSelectShowing = true
                            alertShowing = false
                        }),
                secondaryButton: .cancel())
        }
    }
}

//#Preview {
//    ImageGeneratorView()
//}
