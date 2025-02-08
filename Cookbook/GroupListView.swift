//
//  ShareView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-28.
//

import SwiftUI
import SwiftData

struct GroupListView: View {
    
    @Query var groups: [RecipeGroup]
    
    @State private var addGroupShowing = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groups) { group in
                    Text(group.name)
                }
            }
            .navigationBarItems(trailing: Button {
                addGroupShowing = true
            } label: {
                Label("Add", systemImage: "plus")
            })
            .fullScreenCover(isPresented: $addGroupShowing) {
                @Bindable var recipeGroup: RecipeGroup = RecipeGroup(name: "")
                CreateEditGroupView(recipeGroup: recipeGroup, isNewGroup: true)
            }
        }
    }
}

#Preview {
    GroupListView()
}
