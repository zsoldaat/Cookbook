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
    let name: String?
    let instructions: String?
    let ingredients: [String]?
    let imageUrls: [String]?
    
    init(name: String?, instructions: String?, ingredients: [String]?, imageUrls: [String]?) {
        self.name = name
        self.instructions = instructions
        self.ingredients = ingredients
        self.imageUrls = imageUrls
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
            
            let name = try document.select("h1").first!.text()
            
            let images = try document.select("img")
            
            let imageUrls = try images
                .sorted { first, second in
                    let firstWidth = try Int(first.attr("width")) ?? 0
                    let secondWidth = try Int(second.attr("width")) ?? 0
                    return firstWidth > secondWidth
                }
                .map { element in try element.attr("src") }
                .filter { url in url.contains("https") }
            
            guard let allHeadings = getHeadings(document: document) else {
                print("Could not get headings")
                return nil
            }
            
            let ingredients = getListItemsForTitle(title: "Ingredients", headings: allHeadings)
            
            let instructions = getListItemsForTitle(title: "Instructions", headings: allHeadings)
            
            return RecipeData(name: name, instructions: instructions?.reduce("", {cur, next in cur + (cur.isEmpty ? "" : "\n \n") + next}), ingredients: ingredients, imageUrls: imageUrls)
            
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
