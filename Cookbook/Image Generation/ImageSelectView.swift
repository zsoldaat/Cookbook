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

func fetchImage(query: String) async -> [URL?]? {
    let urlString = "https://www.googleapis.com/customsearch/v1?key=AIzaSyCMjKCwuvZ7iHo23GZQVhwvyzXz0L3n9EY&cx=14d5324c5262949d1&q=\(query)&searchType=image"
    let url = URL(string: urlString)!
    let (data, _) = try! await URLSession.shared.data(from: url)
    
    do {
        let imageResults = try JSONDecoder().decode(ImageResults.self, from: data)
        return imageResults.items.prefix(5).map{ item in
            return URL(string: item.link)
        }
    } catch {
        print("No results")
        return nil
    }
}

struct ImageSelectView: View {
    
    let query: String
    
    @State var imageUrls: [URL?]? = nil
    
    var body: some View {
        VStack {
            if let imageUrls = imageUrls {
                ForEach(imageUrls, id: \.self) { imageUrl in
                    if let imageUrl = imageUrl {
                        AsyncImage(url: imageUrl) { image in
                            image.resizable()
                        } placeholder: {
                            ZStack {
                                Color.gray
                            }
                        }
                        .scaledToFit()
                    } else {
                        Text("No Image")
                    }
                }
            }
        }.task {
            if let urls = await fetchImage(query: query) {
                imageUrls = urls
            }
        }
    }
}

//#Preview {
//    ImageSelectView()
//}
