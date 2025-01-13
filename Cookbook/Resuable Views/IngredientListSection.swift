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
                .draggable("Hello") {
                    Text(ingredient.name)
                }
                .dropDestination(for: String.self) { hello, location in
                    print(hello)
                    return true
                }
                
            }
            .onDelete { indexSet in
                if let onDelete = onDelete {
                    onDelete(indexSet)
                }
            }
        }
        
        //apparently dragging and dropping doesn't work for items in the same list at the moment
        //https://forums.developer.apple.com/forums/thread/730367
        
        //drag and drop tutorial
        //https://www.youtube.com/watch?v=lsXqJKm4l-U
            
    }
}
//
//#Preview {
//    IngredientList(ingredients: [], selection: Set<UUID>())
//}
