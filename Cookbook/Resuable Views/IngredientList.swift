//
//  IngredientList.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-18.
//

import SwiftUI

struct IngredientList: View {
    
    let ingredients: [Ingredient]
    @Binding var selections: Set<UUID>
    var onSwipeGesture: ((Ingredient) -> Void)?
    
    var body: some View {
        List {
            Section(header: Text("Ingredients")) {
                ForEach(ingredients) { ingredient in
                    HStack {
                        Image(systemName: selections.contains(ingredient.id) ? "checkmark.circle" : "circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .onTapGesture {
                                if (selections.contains(ingredient.id)) {
                                    selections.remove(ingredient.id)
                                } else {
                                    selections.insert(ingredient.id)
                                }
                            }
                            

                        IngredientCell(ingredient: ingredient)
                    }.swipeActions {
                        if let onSwipe = onSwipeGesture {
                            Button {
                                onSwipe(ingredient)
                            } label: {
                                Text("HEllo")
                            }
                        }
                        
                    }
                }
            }
        }
    }
}
//
//#Preview {
//    IngredientList(ingredients: [], selection: Set<UUID>())
//}
