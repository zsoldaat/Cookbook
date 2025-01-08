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

struct Scraper {
    
    let url: URL
    
    init (url: URL) {
        self.url = url
    }
    
    func fetchUrl() async -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    func getIngredients() async -> [String]? {
        return await scrapeUrl(for: .ingredients)
    }
    
    func getInstructions() async -> String? {
        
        if let instructions = await scrapeUrl(for: .instructions) {
            return instructions.reduce("", {cur, next in cur + "\n" + "\n" + next})
        }
        
        return nil
    }
    
    func getTitle() async -> String? {
        
        if let title = await scrapeUrl(for: .title)?.first {
            return title
        }
        
        return nil
    }
    
    func scrapeUrl(for infoType: InfoType) async -> [String]? {
        
        guard let html = await fetchUrl() else {
            return nil
        }
        
        do {
            
            let document = try SwiftSoup.parse(html)
            
            if infoType == .title {
                return try [document.select("h1").first!.text()]
            }
            
            guard let allHeadings = await getHeadings(document: document) else {
                print("Could not get headings")
                return nil
            }
            
            if infoType == .ingredients {
                return await getListItemsForTitle(title: "Ingredients", headings: allHeadings)
            }
            
            if infoType == .instructions {
                return await getListItemsForTitle(title: "Instructions", headings: allHeadings)
            }
            
            return nil
            
        } catch {
            print("Didn't work")
            return nil
        }
    }
    
    func getListItemsForTitle(title: String, headings: [Element]) async -> [String]? {
        
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
    
    func getHeadings(document: Document) async -> [Element]? {
        
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
