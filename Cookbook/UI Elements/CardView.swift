//
//  CardView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-09.
//

import SwiftUI

class ActionButton: ObservableObject {
    let icon: String
    @Published var hidden: Bool
    @Published var disabled: Bool
    let action: () -> Void
    
    
    init(icon: String, hidden: Bool? = nil, disabled: Bool? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.hidden = hidden == nil ? false : true
        self.disabled = disabled == nil ? false : true
        self.action = action
    }
}

struct CardView<Content: View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    @ObservedObject var actionButton: ActionButton
    let content: () -> Content
    
    
    init(title: String, actionButton: ActionButton? = nil, @ViewBuilder content: @escaping () -> Content) {
        func hello() {
            
        }
        self.title = title
        self.actionButton = actionButton != nil ? actionButton! : ActionButton(icon: "", hidden: true) { hello() }
        self.content = content
    }
    
    var body: some View {
        
        VStack {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    Spacer()
                    
                    if (!actionButton.hidden) {
                        Button {
                            actionButton.action()
                        } label: {
                            Image(systemName: actionButton.icon)
                        }
                        .disabled(actionButton.disabled)
                    }
                }
                
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
