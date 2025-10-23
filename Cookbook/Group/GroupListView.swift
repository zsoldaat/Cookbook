//
//  ShareView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-28.
//

import SwiftUI
import SwiftData

struct GroupListView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var context
    @EnvironmentObject var dataController: DataController
    
    @Query var groups: [RecipeGroup]
    
    @State private var addGroupShowing = false
    
    var body: some View {
        NavigationStack {
            
            if groups.isEmpty {
                VStack {
                    VStack {
                        Text("There is nothing here.")
                        
                        Button {
                            addGroupShowing = true
                        } label: {
                            Label("Add a group", systemImage: "plus")
                                .labelStyle(.titleAndIcon)
                        }.padding()
                    }
                    .frame(width: 200, height: 200)
                    .background(colorScheme == .dark ? .gray.opacity(0.15) : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.top, 100)
                    
                    Spacer()
                }
            }
            
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
