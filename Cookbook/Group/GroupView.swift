//
//  GroupView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-02-08.
//

import SwiftUI

struct GroupView: View {
    
    @Environment(\.modelContext) var context
    
    let group: RecipeGroup
    
    var body: some View {
        
        List {
            ForEach(group.recipes!) {recipe in
                RecipeCell(recipe: recipe)
            }
            .onDelete { indexSet in
                for i in indexSet {
                    group.removeRecipe(recipe: group.recipes![i])
                }
                try! context.save()
            }
        }
        .navigationTitle(group.name)
    }
}

//#Preview {
//    GroupView()
//}
