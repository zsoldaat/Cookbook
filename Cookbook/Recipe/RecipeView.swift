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
    @EnvironmentObject var dataController: DataController
    
    let recipe: Recipe
    
    @State private var editShowing: Bool = false
    @State private var addToGroupShowing: Bool = false
    
    @State private var isSharing = false
    @State private var isProcessingShare = false
    
    @State private var activeShare: CKShare?
    @State private var activeContainer: CKContainer?
    
    @FocusState var keyboardisActive: Bool
    
    @State var sliderValue: Double = 0
    
    @StateObject private var shareController: ShareController = .init()
    
    var body: some View {
        ScrollView {
            RecipeImageView(recipe: recipe)
            
            CardView(title: "Instructions") {
                Text(recipe.instructions)
            }
            .padding(.horizontal, 5)
            
            IngredientsCard(recipe: recipe)
                .padding(.horizontal, 5)
            
            DifficultyView(recipe: recipe)
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
            
            ToolbarItem(placement: .topBarTrailing){
                Button {
                    addToGroupShowing = true
                } label: {
                    Label("Group", systemImage: "person.2")
                }
                .sheet(isPresented: $addToGroupShowing) {
                    AddToGroupView(recipe: recipe)
                }
            }
        }
    }
}

//needed because if you use a regular state variable, it doesn't work properly because of async issues.
class ShareController: ObservableObject {
    @Published var isSharing: Bool = false
}

