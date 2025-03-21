//
//  NotesView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-03-21.
//

import SwiftUI

struct NotesView: View {
    
    let recipe: Recipe
    @State private var editable: Bool = false
    
    @FocusState var textFieldFocused: Bool
    
    var body: some View {
        CardView(title: "Notes", button: {
            Button{
                editable.toggle()
                textFieldFocused.toggle()
            } label: {
                Label( editable ? "Done" : "Edit", systemImage: "square.and.pencil")
                    .labelStyle(.titleOnly)
            }
        }) {
            let notesBinding = Binding<String>(get: {
                recipe.notes ?? ""
            }, set: {
                recipe.notes = $0
            })
            
            TextField("", text: notesBinding, axis: .vertical)
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
