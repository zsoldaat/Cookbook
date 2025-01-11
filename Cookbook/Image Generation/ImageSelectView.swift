//
//  ImageSelectView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-06.
//

import SwiftUI

struct ImageResults: Codable {
    let items: [ImageResult]
}

struct ImageResult: Codable {
    let title: String
    let link: String
}

func fetchImage(query: String) async -> [URL?] {
    let urlString = "https://www.googleapis.com/customsearch/v1?key=AIzaSyCMjKCwuvZ7iHo23GZQVhwvyzXz0L3n9EY&cx=14d5324c5262949d1&q=\(query)&searchType=image"
    let url = URL(string: urlString)!
    let (data, _) = try! await URLSession.shared.data(from: url)
    
    do {
        let imageResults = try JSONDecoder().decode(ImageResults.self, from: data)
        return imageResults.items.shuffled().prefix(5).map{ item in
            return URL(string: item.link)
        }
    } catch {
        return []
    }
}

struct ImageSelectView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let query: String
    let onSelect: (URL?) -> Void
    @State var textFieldValue: String = ""
    
    @State var imageUrls: [URL?]? = nil
    
    var body: some View {
        VStack {
            
            if let imageUrls = imageUrls {
                if (imageUrls.count > 0) {
                    Text("Select an image to use for this recipe.")
                    ForEach(imageUrls, id: \.self) { imageUrl in
                        if let imageUrl = imageUrl {
                            Button {
                                onSelect(imageUrl)
                                dismiss()
                            } label: {
                                AsyncImage(url: imageUrl) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color.gray
                                }
                                .scaledToFit()
                            }
                        } else {
                            Text("No Image")
                        }
                    }
                } else {
                    Text("Could not retrive any images for this recipe name.")
                    Button {
                        dismiss()
                    } label: {
                        Text("Ok")
                    }
                }
            } else {
                Text("Loading...")
            }
            
            TextField("URL", text: $textFieldValue).onSubmit {
                let url = URL(string: textFieldValue)
                onSelect(url)
                dismiss()
            }
            
        }.task {
            imageUrls = await fetchImage(query: query)
        }
    }
}

//#Preview {
//    ImageSelectView()
//}
