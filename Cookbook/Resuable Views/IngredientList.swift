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
    
    var body: some View {
        List (ingredients, selection: $selections) { ingredient in
            HStack {
                Image(systemName: selections.contains(ingredient.id) ? "checkmark.circle" : "circle")
                    .onTapGesture {
                        if (selections.contains(ingredient.id)) {
                            selections.remove(ingredient.id)
                        } else {
                            selections.insert(ingredient.id)
                        }
                    }
                IngredientCell(ingredient: ingredient)
            }
        }
    }
}
//
//#Preview {
//    IngredientList(ingredients: [], selection: Set<UUID>())
//}
