//
//  AddToGroupView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-02-08.
//

import SwiftUI
import SwiftData

struct AddToGroupView: View {
    
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    let recipe: Recipe
    
    @Query var groups: [RecipeGroup]
    
    var body: some View {
        List {
            ForEach(groups) { group in
                Button {
                    group.addRecipe(recipe: recipe)
                    try! context.save()
                    dismiss()
                } label: {
                    Text(group.name)
                }
            }
        }
    }
}

//#Preview {
//    AddToGroupView()
//}
