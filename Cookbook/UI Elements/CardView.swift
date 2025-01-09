//
//  CardView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-09.
//

import SwiftUI

struct CardView<Content: View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
            self.title = title
            self.content = content
        }
    
    var body: some View {
        
        VStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom)
                   
                content()
            }.padding()
        }
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

//#Preview {
//    CardView()
//}
