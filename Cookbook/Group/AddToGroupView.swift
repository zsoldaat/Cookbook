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
        NavigationStack {
            List {
                ForEach(groups) { group in
                    HStack {
                        Button {
                            group.recipes!.contains(recipe) ? group.removeRecipe(recipe: recipe) : group.addRecipe(recipe: recipe)
                        } label: {
                            Image(systemName: group.recipes!.contains(recipe) ? "checkmark.circle.fill" : "circle")
                        }
                        Text(group.name)
                    }
                }
            }
            .navigationTitle("Groups")
        }
    }
}

//#Preview {
//    AddToGroupView()
//}
