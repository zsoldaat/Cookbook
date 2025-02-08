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
                        .onSubmit {
                            if (recipeGroup.name.isEmpty) {return}
                            
                            context.insert(recipeGroup)
                            try! context.save()
                            dismiss()
                        }
                        .submitLabel(.done)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
}

//#Preview {
//    CreateEditGroupView()
//}
