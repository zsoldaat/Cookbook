//
//  Scraper.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-08.
//

import Foundation
import SwiftSoup

enum InfoType {
    case all, title, ingredients, instructions
}

struct RecipeData {
    let title: String?
    let instructions: String?
    let ingredients: [String]?
    
    init(title: String?, instructions: String?, ingredients: [String]?) {
        self.title = title
        self.instructions = instructions
        self.ingredients = ingredients
    }
}

struct Scraper {
    
    let url: URL
    
    init (url: URL) {
        self.url = url
    }
    
    func getRecipeData() async -> RecipeData? {
        guard let html = await fetchUrl() else {
            return nil
        }
        
        do {
            
            let document = try SwiftSoup.parse(html)
            
            let title = try document.select("h1").first!.text()
            
            guard let allHeadings = getHeadings(document: document) else {
                print("Could not get headings")
                return nil
            }
            
            let ingredients = getListItemsForTitle(title: "Ingredients", headings: allHeadings)
            
            let instructions = getListItemsForTitle(title: "Instructions", headings: allHeadings)
            
            return RecipeData(title: title, instructions: instructions?.reduce("", {cur, next in cur + "\n" + "\n" + next}), ingredients: ingredients)
            
        } catch {
            print("Didn't work")
            return nil
        }
    }
    
    private func fetchUrl() async -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    private func getListItemsForTitle(title: String, headings: [Element]) -> [String]? {
        
        do {
            let titleElement = try headings.first { element in
                return try element.text().contains(title)
            }
            
            if let titleElement = titleElement {
                if let listItems = recurseParentsForListItems(element: titleElement) {
                    return try listItems.map({ element in
                        try element.text()
                    })
                }
            }
            
        } catch {
            print(error)
        }
        return nil
    }
    
    private func getHeadings(document: Document) -> [Element]? {
        
        do {
            let h1Headings = try document.select("h1")
            let h2Headings = try document.select("h2")
            let h3Headings = try document.select("h3")
            
            var allHeadings: [Element] = []
            allHeadings.append(contentsOf: h1Headings)
            allHeadings.append(contentsOf: h2Headings)
            allHeadings.append(contentsOf: h3Headings)
            return allHeadings
        } catch {
            print("Could not get headings")
        }
        
        return nil
    }
    
    func recurseParentsForListItems(element: Element) -> Elements? {
        
        guard let parentElement = element.parent() else { return nil }
        
        do {
            let listItems = try parentElement.select("li")
            if listItems.count == 0 {
                return recurseParentsForListItems(element: parentElement)
            } else {
                return listItems
            }
        } catch {
            return nil
        }
    }
    
}
