//
//  RecipeView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-16.
//

import SwiftUI
import SwiftData
import CloudKit

struct RecipeView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var cloudKitController: CloudKitController
    
    let recipe: Recipe
    
    @State private var editShowing: Bool = false
    
    @State private var isSharing = false
    @State private var isProcessingShare = false

    @State private var activeShare: CKShare?
    @State private var activeContainer: CKContainer?

    @FocusState var keyboardisActive: Bool

    var body: some View {
        ScrollView {
            RecipeImageView(recipe: recipe)
            
            CardView(title: "Instructions") {
                Text(recipe.instructions)
            }
            .padding(.horizontal, 5)
            
            IngredientsCard(recipe: recipe)
                .padding(.horizontal, 5)
            
            CardView(title: "Difficulty") {
                let difficultyBinding = Binding<String>(get: {
                    if recipe.difficulty != nil {
                        return recipe.difficulty!
                    } else {
                        return ""
                    }
                }, set: {
                    recipe.difficulty = $0
                })
                
                Picker("Difficulty", selection: difficultyBinding) {
                    ForEach(["", "Easy", "Medium", "Hard"], id: \.self) { difficulty in
                        Text(difficulty)
                    }
                }
            }
            .padding(.horizontal, 5)
            
            RatingView(recipe: recipe)
                .padding(.horizontal, 5)
            
            CardView(title: "Details") {
                VStack(alignment: .leading) {
                    if let lastMadeDate = recipe.lastMadeDate {
                        HStack {
                            Text("Last Made:").font(.headline)
                            Text(Recipe.dateFormatter.string(from:lastMadeDate)).font(.subheadline)
                        }
                    }
                    
                    if let link = recipe.link {
                        if let url = URL(string:link) {
                            HStack {
                                Text("Link:").font(.headline)
                                Link(link, destination: url).lineLimit(1).font(.subheadline)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 5)
        }
        .fullScreenCover(isPresented: $editShowing, content: {
            @Bindable var recipe = recipe
            CreateEditRecipeView(recipe: recipe, isNewRecipe: false)
        })
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    editShowing = true
                } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                        .labelStyle(.iconOnly)
                }
            }
            
            ToolbarItem {
                Button {
                    isSharing = true
                } label: {
                    Text("Share")
                }
                .sheet(isPresented: $isSharing) {
                    CloudSharingView(container: activeContainer!, share: activeShare!)
                }
                .disabled(activeShare == nil || activeContainer == nil)
            }
        }
        .task {
            do {
                if let (share, container) = try await cloudKitController.fetchOrCreateShare(recipe: recipe) {
                    activeShare = share
                    activeContainer = container
                }
            } catch {
                
            }
            
        }
    }
}


