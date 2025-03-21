//
//  TagsView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-03-21.
//

import SwiftUI
import SwiftData

struct TagsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let recipe: Recipe
    
    @State private var value: String = ""
    @FocusState private var textFieldFocused: Bool
    
    @Query var recipes: [Recipe]
    
    func addTag(name: String) {
        if (name.isEmpty) {return}
        if (recipe.tags!.map{$0.name}.contains(name)) {
            print("Tag already exists")
            return
        }
        recipe.tags?.append(Tag(name: name))
    }
    
    var body: some View {
        VStack {
            if textFieldFocused {
                VStack {
                    ForEach(recipes
                        .map{$0.tags!}
                        .reduce([], {cur, next in cur + next.filter{ tag in !cur.map{$0.name}.contains(tag.name)}})
                        .filter{$0.name.contains(value)}
                        .filter {tag in !recipe.tags!.map{$0.name}.contains(tag.name)}
                        .prefix(3)
                    ) { tag in
                        Button {
                            addTag(name: tag.name)
                            value = ""
                        } label: {
                            Group {
                                Text(tag.name)
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                            }
                            .frame(height: 50)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(.black, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.top, 2)
            }
            
            CardView(title: "Tags") {
                VStack {
                    TextField("Add a tag", text: $value)
                        .onSubmit {
                            addTag(name: value)
                            value = ""
                        }
                        .submitLabel(.done)
                        .focused($textFieldFocused)
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(recipe.tags?.reversed() ?? []) {tag in
                                ChipView {
                                    HStack {
                                        Text(tag.name)
                                        Button {
                                            recipe.tags?.removeAll { $0.id == tag.id }
                                        } label: {
                                            Label("Remove", systemImage: "x.circle.fill")
                                                .labelStyle(.iconOnly)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    .scrollIndicators(.hidden)
                }
            }
        }
    }
}
