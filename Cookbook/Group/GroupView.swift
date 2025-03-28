//
//  GroupView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-02-08.
//

import SwiftUI
import CloudKit

struct GroupView: View {
    
    @Environment(\.modelContext) var context
    @EnvironmentObject var dataController: DataController
    
    @State private var activeShare: CKShare?
    @State private var activeContainer: CKContainer?
    @State private var isSharing: Bool = true
    
    let group: RecipeGroup
    
    @StateObject private var shareController: ShareController = .init()
    
    var body: some View {
        List {
            ForEach(group.recipes!) {recipe in
                NavigationLink {
                    RecipeView(recipe: recipe)
                } label: {
                    RecipeCell(recipe: recipe)
                        .swipeActions {
                            Button(role: .destructive) {
                                group.removeRecipe(recipe: recipe)
                                try! context.save()
                                
                                if group.isShared {
                                    Task {
                                        try! await dataController.updateRecipesForSharedGroup(group: group)
                                    }
                                }
                            } label: {
                                Label("Delete", systemImage: "xmark.circle")
                                    .labelStyle(.iconOnly)
                            }
                            .tint(.red)
                        }
                }
            }
        }
        .navigationTitle(group.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        do {
                            if let (share, container) = try await dataController.fetchOrCreateGroupShare(group: group, scope: .private) {
                                activeShare = share
                                activeContainer = container
                                shareController.isSharing = true
                            }
                        } catch {
                            print("Error creating share: \(error)")
                        }
                    }
                } label: {
                    Label("Share", systemImage: "person.circle")
                }
                .sheet(isPresented: $shareController.isSharing, onDismiss: {
                    shareController.isSharing = false
                }) {
                    //                    ShareLink(item: activeShare!.url!)
                    CloudSharingView(container: activeContainer!, share: activeShare!)
                }
            }
        }
    }
}

//#Preview {
//    GroupView()
//}
