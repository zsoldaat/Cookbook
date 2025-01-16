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
    
    func onSelect(url: URL?) -> Void {
        
        if let url = url {
            recipe.addImage(url: url, context: context)
        }
    }
    
    var body: some View {
        
        AsyncImage(url: recipe.imageUrl) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: 250, alignment: .center)
                .clipped()
                .onLongPressGesture {
                    alertShowing = true
                }
        } placeholder: {
            if (recipe.imageUrl !=  nil) {
                Color.gray.frame(height: 250)
            } else {
                Color.gray.frame(height: 250).overlay {
                    Button {
                        imageSelectShowing = true
                    } label: {
                        Label("Generate an image", systemImage: "photo.badge.plus")
                    }
                }
            }
        }
        .overlay(alignment: .bottomLeading) {
            Text(recipe.name)
            
                .font(.largeTitle)
                .bold()
                .shadow(color: .black, radius: 1)
                .foregroundStyle(.white)
                .padding()
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
