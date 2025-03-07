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
    @EnvironmentObject var dataController: DataController
    let recipe: Recipe
    
    @Query var groups: [RecipeGroup]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groups) { group in
                    HStack {
                        Button {
                            if group.recipes!.contains(recipe) {
                                group.removeRecipe(recipe: recipe)
                            } else {
                                group.addRecipe(recipe: recipe)
                            }
                            try! context.save()
                            
                            if group.isShared {
                                Task {
                                    try! await dataController.updateRecipesForSharedGroup(group: group)
                                }
                            }
                        } label: {
                            Image(systemName: group.recipes!.contains(recipe) ? "checkmark.circle.fill" : "circle")
                        }
                        GroupCell(group: group)
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
