//
//  CreateEditGroupView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-02-08.
//

import SwiftUI

struct CreateEditGroupView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    @Bindable var recipeGroup: RecipeGroup
    let isNewGroup: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("", text: $recipeGroup.name)
                }
            }
            .navigationBarItems(trailing: Button{
                context.insert(recipeGroup)
                try! context.save()
                dismiss()
            } label: {
                Label("Done", systemImage: "checkmark")
            })
        }
    }
}

//#Preview {
//    CreateEditGroupView()
//}
