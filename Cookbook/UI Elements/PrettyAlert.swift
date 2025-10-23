//
//  PrettyAlert.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-03-10.
//

import SwiftUI

struct PrettyAlert: View {
    
    @Binding var isShowing: Bool
    let text: String
    let icon: String
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if isShowing {
            VStack {
                VStack {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 75, height: 75)
                        .padding()
                    Text(text)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 200, height: 200)
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .opacity(0.9)
                .padding(50)
                
                Spacer()
            }
            .onReceive(timer, perform: { _ in
                if isShowing {
                    withAnimation {
                        isShowing = false
                    }

                }
            })
        }
    }
}

//#Preview {
//    PrettyAlert()
//}
