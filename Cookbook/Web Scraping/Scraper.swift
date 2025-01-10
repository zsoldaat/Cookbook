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

//func findUnit(in string: String) -> String? {
//    
//    if string.contains("cup") || string.contains("cups") {
//        return "cup"
//    }
//    
//    if string.contains("quart") || string.contains("quarts") {
//        return "quart"
//    }
//    
//    if string.contains("tsp") || string.contains("tsps") || string.contains("teaspoon") || string.contains("teaspoons") {
//        return "tsp"
//    }
//    
//    if string.contains("tbsp") || string.contains( "tbsps") || string.contains("tablespoon") || string.contains("tablespoons") {
//        return "tbsp"
//    }
//    
//    if string.contains("mL") || string.contains("mls") || string.contains("milliliter") || string.contains("milliliters") {
//        return "mL"
//    }
//    
//    if string.contains("L") || string.contains("ls") || string.contains("liter") || string.contains("liters") {
//        return "L"
//    }
//    
//    if string.contains("oz") || string.contains("ounce") || string.contains("ounces") {
//        return "oz"
//    }
//    
//    if string.contains("lb") || string.contains("lbs") || string.contains("pound") || string.contains("pounds") {
//        return "lb"
//    }
//    
//    if string.contains( "g") || string.contains("gram") || string.contains("grams") {
//        return "g"
//    }
//    
//    if string.contains("kg") || string.contains("kilogram") || string.contains("kilograms") {
//        return "kg"
//    }
//    
//    if string.contains("pinch") || string.contains("pinches") {
//        return "pinch"
//    }
//    
//    return nil
//}

func findUnit(in string: String) -> String? {
    
    if string == "cup" || string == "cups" {
        return "cup"
    }
    
    if string == "quart" || string == "quarts" {
        return "quart"
    }
    
    if string == "tsp" || string == "tsps" || string == "teaspoon" || string == "teaspoons"{
        return "tsp"
    }
    
    if string == "tbsp" || string == "tbsps" || string == "tablespoon" || string == "tablespoons" {
        return "tbsp"
    }
    
    if string == "mL" || string == "mLs" || string == "milliliter" || string == "milliliters" {
        return "mL"
    }
    
    if string == "L" || string == "Ls" || string == "liter" || string == "liters" {
        return "L"
    }
    
    if string == "oz" || string == "ounce" || string == "ounces" {
        return "oz"
    }
    
    if string == "lb" || string == "lbs" || string == "pound" || string == "pounds" {
        return "lb"
    }
    
    if string == "g" || string == "gram" || string == "grams" {
        return "g"
    }
    
    if string == "kg" || string == "kilogram" || string == "kilograms" {
        return "kg"
    }
    
    if string == "pinch" || string == "pinches" {
        return "pinch"
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
        
        var workingString = ingredient
        var quantity: String = ""
        var unit: String = ""
        
        if let foundQuantity = getQuantityPart(string: workingString) {
            quantity = foundQuantity[0]
            workingString = foundQuantity[1]
        }
        
        if let foundUnit = getUnitPart(string: workingString) {
            unit = foundUnit[0]
            workingString = foundUnit[1]
        }
        
        let parsedQuantity = parseQuantityPart(string: quantity)
        
        let name = workingString.prefix(1).uppercased() + workingString.dropFirst()
        
        let ingredient = Ingredient(name: name, quantityWhole: parsedQuantity?.whole ?? 1, quantityFraction: Ingredient.fractionToDouble(fraction: parsedQuantity?.fraction ?? ""), unit: unit.isEmpty ? "item" : unit, index: index)
        
        return ingredient
    }
    
    private func getUnitPart(string: String) -> [String]? {
        //keep only alphanumerics and spaced, split into array
        let words = String(string.unicodeScalars
            .filter {char in CharacterSet.alphanumerics.contains(char) || CharacterSet.whitespaces.contains(char) || char == "-" || char == "/"})
            .split(separator: " ")
            .map { substring in "\(substring)" }
        
        if words.count > 0 {
            if let unit = findUnit(in: words.first!) {
                return [unit, words[1...].joined(separator: " ")]
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
        let quantityValues = string.components(separatedBy: CharacterSet(charactersIn: "-–"))
        
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
