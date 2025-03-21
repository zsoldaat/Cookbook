//
//  GradientSlider.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-03-21.
//

import SwiftUI

struct GradientSlider: View {
    
    @Binding var value: Float
    
    var body: some View {
        ZStack {
            
            LinearGradient(
                gradient: Gradient(colors: [.green, .red]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .mask(Slider(value: $value, in: 0...100))
            
            // Dummy replicated slider, to allow sliding
            Slider(value: $value, in: 0...100).opacity(0.1)
        }
    }
}
