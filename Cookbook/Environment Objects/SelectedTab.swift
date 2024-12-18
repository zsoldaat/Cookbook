//
//  SelectedTab.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2024-12-18.
//

import Foundation

class SelectedTab: ObservableObject {
    @Published var selectedTabTag: Int
    
    init(selectedTabTag: Int) {
        self.selectedTabTag = selectedTabTag
    }
}
