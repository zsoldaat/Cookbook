//
//  IngredientsCard.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-12.
//

import SwiftUI
import SwiftData

struct IngredientsCard: View {
    
    @Environment(\.modelContext) var context
    @Query var shoppingLists: [ShoppingList]
    
    let recipe: Recipe
    
    @State private var showAlert = false
    @State private var selections = Set<UUID>()
    @State private var scaleFactor: Int = 1
    @State private var parsedIngredientsShowing = false
    
    @State private var activeCardIndex: Int? = 0
    
    @State private var ingredientText: String = ""
    @State private var isIngredientTextEditing: Bool = false
    
    var body: some View {
        @Bindable var shoppingList = shoppingLists.first!
        
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                Group {
                    CardView(title: "Ingredients", button: {
                        
                        HStack(alignment: .center) {
                            Group {
                                Button {
                                    selections = Set(recipe.ingredients!.map{$0.id}.filter{!selections.contains($0)})
                                } label: {
                                    Label("Reverse selected", systemImage: "switch.2")
                                        .labelStyle(.iconOnly)
                                }
                                
                                Button {
                                    selections.removeAll()
                                } label: {
                                    Label("Clear selections", systemImage: "xmark.circle")
                                        .labelStyle(.iconOnly)
                                }
                                .disabled(selections.isEmpty)
                                
                                Button {
                                    recipe.ingredients!
                                        .filter {item in
                                            selections.contains(item.id)
                                        }
                                        .forEach { ingredient in
                                            //add ingredients multiple times if scaling up the recipe
                                            for _ in 1...scaleFactor {
                                                shoppingList.addItem(ingredient)
                                            }
                                        }
                                    shoppingList.save(context: context)
                                    selections.removeAll()
                                    recipe.lastMadeDate = Date()
                                    showAlert = true
                                } label: {
                                    Label("Add to Grocery List", systemImage: "text.badge.plus")
                                        .labelStyle(.iconOnly)
                                }
                                .disabled(selections.isEmpty)
                            }
                            .frame(width: 30, height: 30)
                            .padding(.horizontal, 2)
                        }
                    }) {
                        
                        HStack {
                            Spacer()
                            
                            let scaleBinding = Binding<String>(get: {
                                String(scaleFactor) + "x"
                            }, set: {
                                scaleFactor = Int($0.prefix(1))!
                            })
                            
                            Picker("Scale", selection: scaleBinding) {
                                ForEach( ["1x", "2x", "3x", "4x"], id: \.self) { factor in
                                    Text(factor)
                                }
                            }
                        }
                        
                        ForEach(recipe.ingredients!.sorted {$0.index < $1.index}) { ingredient in
                            HStack {
                                Button {
                                    if (selections.contains(ingredient.id)) {
                                        selections.remove(ingredient.id)
                                    } else {
                                        selections.insert(ingredient.id)
                                    }
                                } label: {
                                    Image(systemName: selections.contains(ingredient.id) ? "checkmark.circle.fill" : "circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25)
                                }.sensoryFeedback(trigger: selections.contains(ingredient.id)) { oldValue, newValue in
                                    return .increase
                                }
                                IngredientCell(ingredient: ingredient, scaleFactor: $scaleFactor)
                            }
                            //Specify height to help the scrollview become the right size, maybe fix later to something dynamic?
                            .frame(height: 50)
                        }
                    }
                    .id(0)
                    
                    CardView(title: "Ingredients", button: {
                        Button {
                            if isIngredientTextEditing {
                                let scraper = Scraper()
                                
                                let ingredientList: [String] = ingredientText.split(separator: "\n").map{String($0)}
                                
                                recipe.ingredients = ingredientList.enumerated().map{ (index, ingredientString) in
                                    return scraper.parseIngredientFromString(ingredient: ingredientString, index: index)
                                }
                            }
                            isIngredientTextEditing.toggle()
                            
                        } label: {
                            Label(isIngredientTextEditing ? "Done" : "Edit", systemImage: isIngredientTextEditing ? "square.and.pencil.circle.fill" : "square.and.pencil.circle")
                                .labelStyle(.titleOnly)
                        }
                    }) {
                        TextField("", text: $ingredientText, axis: .vertical)
                            .lineLimit(nil)
                            .disabled(!isIngredientTextEditing)
                            
                        
                        Spacer()
                    }
                    .id(1)
                    .background(Color.gray.opacity(isIngredientTextEditing ? 0.1 : 0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.accent, lineWidth: isIngredientTextEditing ? 2 : 0)
                    )
                }
                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $activeCardIndex)
        .scrollIndicators(.hidden)
        .alert("Ingredients Added", isPresented: $showAlert, actions: {})
        .onAppear {
            var totalString = ""
            
            for ingredient in recipe.ingredients!.sorted(by: {$0.index < $1.index}) {
                let ingredientString = ingredient.getString()
                totalString += ingredientString + "\n"
            }
            
            ingredientText = totalString
        }
        
        HStack {
            Spacer()
            ForEach(0...1, id: \.self) {id in
                Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10)
                    .padding(2)
                    .foregroundStyle(.gray)
                    .opacity(activeCardIndex == id ? 1 : 0.5)
            }
            Spacer()
        }
    }
}
//
//#Preview {
//    IngredientsCard()
//}
