//
//  ListButton.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-08.
//

import SwiftUI

struct ListButton: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var text: String
    var imageSystemName: String?
    var onClick: () -> Void
    
    var body: some View {
        Button {
            onClick()
        } label: {
            HStack {
                Spacer()
                if imageSystemName != nil {
                    Image(systemName: imageSystemName!)
                        .font(.body.bold())
                        .padding(.trailing, 5.0)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                }
                Text(text)
                    .font(.body.bold())
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .frame(height: 44.0)
        .background(Color.blue)
        .cornerRadius(10.0)
        .contentShape(Rectangle())
        .listRowInsets(EdgeInsets())
    }
}

//#Preview {
//    ListButton()
//}
