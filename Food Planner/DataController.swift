//
//  DataController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 12/12/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import Foundation
import Alamofire
import HTMLReader

class DataController {

    let URLString = "http://www.dk-kogebogen.dk/opskrifter/visopskrift_tom_koleskab_app.php?id=28546"
    
    func fetchDish(completionHandler: (Dish?, NSError?) -> Void) {
        var dish: Dish?
        Alamofire.request(.GET, URLString)
            .responseString { responseString in
                guard responseString.result.error == nil else {
                    completionHandler(nil,responseString.result.error!)
                    return
                }
                guard let htmlAsString = responseString.result.value else {
                    let error = Error.errorWithCode(.StringSerializationFailed, failureReason: "Could not get HTML as String")
                    completionHandler(nil,error)
                    return
                }

                let doc = HTMLDocument(string: htmlAsString)
                var name: String?
                var ingredients = [Product]()
                let recipe = ""
                var persons: Int?
                let id = 16202
                
                // find the title in the HTML
                if let nameNode = doc.firstNodeMatchingSelector("center") {
                    let trimmedName = nameNode.textContent.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    name = trimmedName
                }
                
                // find persons - persons is span tag with text "yield" inside
                let spanNodes = doc.nodesMatchingSelector("span")
                for node in spanNodes {
                    if let htmlNode = node as? HTMLElement {
                        if let itemprop = htmlNode.objectForKeyedSubscript("itemprop") as? String {
                            if itemprop == "recipeYield" {
                                persons = self.findIntegerInString(htmlNode.textContent)
                            }
                        }
                    }
                }
                
                //find ingredients - each row in the table 1 ingredient
                let tables = doc.nodesMatchingSelector("table")
                //ingredients table is the last table
                let table = tables[tables.count-1]
                for row in table.nodesMatchingSelector("tr") {
                    let cells = row.nodesMatchingSelector("td")

                    //first element is weight, second is unit, third is name
                    let pWeight = cells[0].textContent
                    let pUnit = cells[1].textContent
                    let pName = cells[2].textContent

                    var ingredient: Product?
                    if (pWeight != "") && (pUnit != "") && (pName != "") {
                        //Check whether unit and weight is correctly formatted
                        if let weight = Int(self.trimString(pWeight)) {
                            //Trim unit and replace it with known(if unknown)
                            if let unit = Unit(rawValue: self.trimString(pUnit)) {
                                
                                ingredient = Product(name: pName, weight: weight, unit: unit, dateExpires: NSDate.init())
                                
                            } else {
                                print("Unit for \(pName) is not valid:" + pUnit)
                            }
                        } else {
                            print("Weight for \(pName) can not be cast to Int:" + pWeight)
                        }
                    }
                    
                    if let ingredient = ingredient {
                        ingredients.append(ingredient)
                    }
                }
                
                
                if let name = name, persons = persons {
                    dish = Dish(name: name, ingredients: ingredients, recipe: recipe, persons: persons, id: id)
                }
                completionHandler(dish,nil)
        }
    }
    
    private func findIntegerInString(input: String) -> Int {
        let scanner = NSScanner(string: input)
        var value: Int = 0

        scanner.scanUpToCharactersFromSet(NSCharacterSet.decimalDigitCharacterSet(), intoString: nil)
        if scanner.scanInteger(&value) {
            print("did scan \(value) in string")
        }
        else {
            print("can't scan integer")
        }
        return value
    }

    private func trimString(input: String) -> String {
        var resultString = input.lowercaseString
        //Remove .
        resultString = resultString.stringByReplacingOccurrencesOfString(".", withString: "")
        //Remove whitespace
        resultString = resultString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return resultString
    }
}