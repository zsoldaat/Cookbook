//
//  CardView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-09.
//

import SwiftUI

struct CardView<Content: View, ButtonContent: View>: View {
    
    let title: String?
    let button: () -> ButtonContent?
    let content: () -> Content
    
    
    init(title: String? = nil, @ViewBuilder button: @escaping () -> ButtonContent? = { EmptyView() }, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.button = button
        self.content = content
    }
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    if let title = title {
                        Text(title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom)
                    }
                    
                    Spacer()
                    button()
                }
                content()
            }.padding()
        }
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

//#Preview {
//    CardView()
//}
