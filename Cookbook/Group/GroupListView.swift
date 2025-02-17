//
//  ShareView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-28.
//

import SwiftUI
import SwiftData

struct GroupListView: View {
    
    @Environment(\.modelContext) var context
    
    @Query var groups: [RecipeGroup]
    
    @State private var addGroupShowing = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groups) { group in
                    NavigationLink {
                        GroupView(group: group)
                            .swipeActions {
                                Button(role: .destructive) {
                                    context.delete(group)
                                    try! context.save()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .labelStyle(.iconOnly)
                                }
                                .tint(.red)
                            }
                    } label: {
                        Text(group.name)
                    }
                    
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addGroupShowing = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .fullScreenCover(isPresented: $addGroupShowing) {
                @Bindable var recipeGroup: RecipeGroup = RecipeGroup(name: "")
                CreateEditGroupView(recipeGroup: recipeGroup, isNewGroup: true)
            }
            .navigationTitle("Groups")
        }
    }
}

//#Preview {
//    GroupListView()
//}
