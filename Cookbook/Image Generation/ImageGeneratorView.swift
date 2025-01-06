//
//  ImageGeneratorView.swift
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

func fetchImage(query: String) async -> URL? {
    let urlString = "https://www.googleapis.com/customsearch/v1?key=AIzaSyCMjKCwuvZ7iHo23GZQVhwvyzXz0L3n9EY&cx=14d5324c5262949d1&q=\(query)&searchType=image"
    let url = URL(string: urlString)!
    let (data, _) = try! await URLSession.shared.data(from: url)
    
    do {
        let imageResults = try JSONDecoder().decode(ImageResults.self, from: data)
        return URL(string: imageResults.items[0].link)
    } catch {
        print("No results")
        return nil
    }
}

struct ImageGeneratorView: View {
    
    let query: String
    
    @State var imageUrl: URL?
    
    var body: some View {
        VStack {
            if let url = imageUrl {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }

            }
        }.task {
            if let url = await fetchImage(query: query) {
                imageUrl = url
            }
        }
    }
}

//#Preview {
//    ImageGeneratorView()
//}
