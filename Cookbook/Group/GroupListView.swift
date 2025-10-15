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
    @EnvironmentObject var dataController: DataController
    
    @Query var groups: [RecipeGroup]
    
    @State private var addGroupShowing = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groups) { group in
                    NavigationLink {
                        GroupView(group: group)
                    } label: {
                        GroupCell(group: group)
                            .swipeActions {
                                Button(role: .destructive) {
                                    context.delete(group)
                                    try! context.save()
                                    
                                    Task {
                                        if group.isShared {
                                            try! await dataController.deleteGroupShare(group: group)
                                        }
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .labelStyle(.iconOnly)
                                }
                                .tint(.red)
                            }
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
