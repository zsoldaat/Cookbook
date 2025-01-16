//
//  ChipView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-16.
//

import SwiftUI

struct ChipView<Content:View>: View {
    
    let content: () -> Content
    
    init( @ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        
        Group {
            content()
                .padding(.horizontal)
        }
        .frame(height: 30)
        .frame(minWidth: 60)
        .background(Color.accent.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

//#Preview {
//    ChipView()
//}
