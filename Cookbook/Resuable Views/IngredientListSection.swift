//
//  IngredientList.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-18.
//

import SwiftUI

struct IngredientListSection: View {
    
    var ingredients: [Ingredient]
    @Binding var selections: Set<UUID>
    var onDelete: ((IndexSet) -> Void)?
    
    var body: some View {
        Section(header: Text("Ingredients")) {
            ForEach(ingredients.sorted {$0.index < $1.index}) { ingredient in
                HStack {
                    Image(systemName: selections.contains(ingredient.id) ? "circle.fill" : "circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                        .onTapGesture {
                            if (selections.contains(ingredient.id)) {
                                selections.remove(ingredient.id)
                            } else {
                                selections.insert(ingredient.id)
                            }
                        }
                        .sensoryFeedback(trigger: selections.contains(ingredient.id)) { oldValue, newValue in
                            return .increase
                        }
                    IngredientCell(ingredient: ingredient)
                }
//                .draggable(ingredient) {
//                    Text(ingredient.name)
//                }
//                .dropDestination(for: Ingredient.self, action: { ingredient, location in
//                    print(ingredient)
//                    return false
//                })
            }
            .onDelete { indexSet in
                if let onDelete = onDelete {
                    onDelete(indexSet)
                }
            }
        }
    }
}
//
//#Preview {
//    IngredientList(ingredients: [], selection: Set<UUID>())
//}
