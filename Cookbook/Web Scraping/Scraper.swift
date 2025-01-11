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
    let ingredients: [Ingredient]?
    let imageUrls: [String]?
    
    init(name: String?, instructions: String?, ingredients: [Ingredient]?, imageUrls: [String]?) {
        self.name = name
        self.instructions = instructions
        self.ingredients = ingredients
        self.imageUrls = imageUrls
    }
}

struct IngredientQuantity {
    let whole: Int
    let fraction: String?
}

func findUnit(in string: String) -> Unit? {
    
    let lowerString = string.lowercased()
    
    if lowerString == "cup" || lowerString == "cups" {
        return .cup
    }
    
    if lowerString == "quart" || lowerString == "quarts" {
        return .quart
    }
    
    if lowerString == "tsp" || lowerString == "tsps" || lowerString == "teaspoon" || lowerString == "teaspoons"{
        return .tsp
    }
    
    if lowerString == "tbsp" || lowerString == "tbsps" || lowerString == "tablespoon" || lowerString == "tablespoons" {
        return .tbsp
    }
    
    if lowerString == "mL" || lowerString == "mLs" || lowerString == "milliliter" || lowerString == "milliliters" {
        return .mL
    }
    
    if lowerString == "L" || lowerString == "Ls" || lowerString == "liter" || lowerString == "liters" {
        return .L
    }
    
    if lowerString == "oz" || lowerString == "ounce" || lowerString == "ounces" {
        return .oz
    }
    
    if lowerString == "lb" || lowerString == "lbs" || lowerString == "pound" || lowerString == "pounds" {
        return .lb
    }
    
    if lowerString == "g" || lowerString == "gram" || lowerString == "grams" {
        return .g
    }
    
    if lowerString == "kg" || lowerString == "kilogram" || lowerString == "kilograms" {
        return .kg
    }
    
    if lowerString == "pinch" || lowerString == "pinches" {
        return .pinch
    }
    
    return nil
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
            
            //Sometimes sites use the term "instructions", sometimes "preparations", so look for both
            let instructions = getListItemsForTitle(title: "Instructions", headings: allHeadings)?.reduce("", {cur, next in cur + (cur.isEmpty ? "" : "\n \n") + next})
            let preparation = getListItemsForTitle(title: "Preparation", headings: allHeadings)?.reduce("", {cur, next in cur + (cur.isEmpty ? "" : "\n \n") + next})
            
            let ingredients = getListItemsForTitle(title: "Ingredients", headings: allHeadings)
            let ingredientObjects: [Ingredient]? = ingredients != nil ? ingredients!.map{ parseIngredient(ingredient: $0, index: (ingredients?.firstIndex(of: $0))!) } : nil
            
            return RecipeData(name: name, instructions: instructions ?? preparation, ingredients: ingredientObjects, imageUrls: imageUrls)
            
        } catch {
            print("Didn't work")
            return nil
        }
    }
    
    private func parseIngredient(ingredient: String, index: Int) -> Ingredient {
        
        
        var remainingStringToParse = ingredient
        
        //This replace helps down the chain. Basically the rest of this chain assumed that an ingredient will be in the following format: "1 - 2 tablespoons olive oil", where the first letter marks the end of the "quantity" portion of the recipe.
        //When recipes write "1 to 2 tablespoons olive oil, my assumption is not true, so we replace " to " before we continue. However, we only replace instances of " to " until the last number in the string,
        //so we don't turn things like "salt, to taste" into "salt, - taste".
        let lastNumber = remainingStringToParse.lastIndex { char in
            char.isNumber
        }
        
        if let lastNumber = lastNumber {
            var stringUpToLastNumber = String(remainingStringToParse.prefix(upTo: lastNumber))
            let stringFromLastNumber = remainingStringToParse.suffix(from: lastNumber)
            
            if let range = stringUpToLastNumber.range(of:" to ") {
                stringUpToLastNumber = stringUpToLastNumber.replacingCharacters(in: range, with:" - ")
            }
            //combine them back together once the replacement is made
            remainingStringToParse = "\(stringUpToLastNumber)\(stringFromLastNumber)"
        }
        
        var quantity: String = ""
        var unit: Unit? = nil
        
        if let foundQuantity = getQuantityPart(string: remainingStringToParse) {
            quantity = foundQuantity[0]
            remainingStringToParse = foundQuantity[1]
        }
        
        if let foundUnit = getUnitPart(string: remainingStringToParse) {
            unit = foundUnit.keys.first!
            remainingStringToParse = foundUnit.values.first!
        }
        
        let parsedQuantity = parseQuantityPart(string: quantity)
        
        let name = remainingStringToParse.prefix(1).uppercased() + remainingStringToParse.dropFirst()
        
        let ingredient = Ingredient(name: name, quantityWhole: parsedQuantity?.whole ?? 1, quantityFraction: Ingredient.fractionToDouble(fraction: parsedQuantity?.fraction ?? ""), unit: unit ?? .item, index: index)
        
        return ingredient
    }
    
    private func getUnitPart(string: String) -> [Unit: String]? {
        //keep only alphanumerics and spaced, split into array
        let words = String(string.unicodeScalars
            .filter {char in CharacterSet.alphanumerics.contains(char) || CharacterSet.whitespaces.contains(char) || char == "-" || char == "/"})
            .split(separator: " ")
            .map { substring in "\(substring)" }
        
        if words.count > 0 {
            if let unit = findUnit(in: words.first!) {
                return [unit: words[1...].joined(separator: " ")]
            }
        }
        
        return nil
        
    }
    
    private func getQuantityPart(string: String) -> [String]? {
        
        let firstLetter = string.firstIndex { char in
            char.isLetter
        }
        
        if let firstLetter = firstLetter {
            let numberPart = string.prefix(upTo: firstLetter)
            let rest = string.suffix(from: firstLetter)
            return ["\(numberPart)".trimmingCharacters(in: .whitespacesAndNewlines), "\(rest)".trimmingCharacters(in: .whitespacesAndNewlines)]
        }
        
        return nil
    }
    
    
    private func parseQuantityPart(string: String) -> IngredientQuantity? {
        //Handles the situation where recipes will write "1 1/2 - 2 tablespoons...", we split based on the dash and then carry out operations going forward on both of the numbers
        let quantityValues = string.split { $0 == "-" || $0 == "–"}
        
        let ingredientQuantities: [IngredientQuantity] = quantityValues.map { quantity in
            
            var whole = 1
            var fraction = ""
            
            //find fractions if there are any
            if let indexOfSplit = quantity.firstIndex(of: "/") {
                let firstHalfOfFraction = quantity.prefix(upTo: indexOfSplit).last!
                let lastHalfOfFraction = quantity.suffix(from: indexOfSplit)
                fraction = "\(firstHalfOfFraction)\(lastHalfOfFraction)".trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            //remove occurences of the fraction (if any), leaving the whole part remaining
            let wholePart = String(quantity.replacingOccurrences(of: fraction, with: "").unicodeScalars.filter {CharacterSet.decimalDigits.contains($0)}).trimmingCharacters(in: .whitespacesAndNewlines)
            
            if Int(wholePart) != nil {
                whole = Int(wholePart)!
            } else {
                if fraction.isEmpty {
                    whole = 1
                } else {
                    whole = 0
                }
            }
            
            return IngredientQuantity(whole: whole, fraction: fraction)
        }
        
        //Just return the first of the quantities if there are multiple, i.e. if the quantity of the ingredient in the recipe is "1 1/2 - 2 tablespoons...", we just return the "1 1/2"
        return ingredientQuantities.first
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
