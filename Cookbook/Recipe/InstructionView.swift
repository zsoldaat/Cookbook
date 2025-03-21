//
//  NotesView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-03-21.
//

import SwiftUI

struct InstructionView: View {
    
    let recipe: Recipe
    @State private var editable: Bool = false
    @FocusState private var textFieldFocused: Bool
    
    var body: some View {
        CardView(title: "Instructions", button: {
            Button{
                editable.toggle()
                textFieldFocused.toggle()
            } label: {
                Label( editable ? "Done" : "Edit", systemImage: "square.and.pencil")
                    .labelStyle(.titleOnly)
            }
        }) {
            let instructionBinding = Binding<String>(get: {
                recipe.instructions
            }, set: {
                recipe.instructions = $0
            })
            
            TextField("", text: instructionBinding, axis: .vertical)
                .lineLimit(5...)
                .disabled(!editable)
                .focused($textFieldFocused)
            
            Spacer()
        }
        .background(Color.gray.opacity(editable ? 0.1 : 0))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.accent, lineWidth: editable ? 2 : 0)
        )
    }
}
