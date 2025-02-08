//
//  GroupView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-02-08.
//

import SwiftUI

struct GroupView: View {
    
    let group: RecipeGroup
    
    var body: some View {
        
        List {
            ForEach(group.recipes!) {recipe in
                Text(recipe.name)
            }
        }
        .navigationTitle(group.name)
    }
}

//#Preview {
//    GroupView()
//}
