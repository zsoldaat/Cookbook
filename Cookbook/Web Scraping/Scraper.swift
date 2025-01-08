//
//  Scraper.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-08.
//

import Foundation
import SwiftSoup

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
    
    func scrapeUrl () async {
        
        guard let html = await fetchUrl() else {
            return
        }
        
        do {
            
            let document = try SwiftSoup.parse(html)
            
            guard let allHeadings = await getHeadings(document: document) else {
                print("Could not get headings")
                return
            }
            
            guard let instructions = await getListItemsForTitle(title: "Instructions", headings: allHeadings) else {
                return
            }
            
            guard let ingredients = await getListItemsForTitle(title: "Ingredients", headings: allHeadings) else {
                return
            }
            
        } catch {
            print("Didn't work")
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
