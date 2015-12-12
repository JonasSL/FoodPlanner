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

    var dish: Dish?
    let URLString = "http://www.dk-kogebogen.dk/opskrifter/visopskrift_tom_koleskab_app.php?id=16202"

    
    func fetchDish() {
        Alamofire.request(.GET, URLString)
            .responseString { responseString in
                guard responseString.result.error == nil else {
                    //completionHandler(responseString.result.error!)
                    return

                }
                guard let htmlAsString = responseString.result.value else {
                    let error = Error.errorWithCode(.StringSerializationFailed, failureReason: "Could not get HTML as String")
                    //completionHandler(error)
                    return
                }

                let doc = HTMLDocument(string: htmlAsString)
                var name: String?
                var ingredients: [Product]?
                let recipe = ""
                var persons: Int?
                let id = 16202
                
                // find the title in the HTML
                if let nameNode = doc.firstNodeMatchingSelector("center") {
                    let trimmedName = nameNode.textContent.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    print(trimmedName)
                    name = trimmedName
                }
                
                
                // find persons - persons is span tag with text "yield" inside
                let spanNodes = doc.nodesMatchingSelector("span")
                for node in spanNodes {
                    if let htmlNode = node as? HTMLElement {
                        if let itemprop = htmlNode.objectForKeyedSubscript("itemprop") as? String {
                            if itemprop == "recipeYield" {
                                //print(htmlNode.textContent)
                                //print(self.findIntegerInString(htmlNode.textContent))
                                persons = self.findIntegerInString(htmlNode.textContent)
                            }
                        }
                        
                    }
                }
                
                if let name = name, ingredients = ingredients, persons = persons {
                    self.dish = Dish(name: name, ingredients: ingredients, recipe: recipe, persons: persons, id: id)
                }
                //completionHandler(nil)
        }
    }
    
    private func findIntegerInString(input: String) -> Int {
        let scanner = NSScanner(string: input)
        var value: Int = 0

        scanner.scanUpToCharactersFromSet(NSCharacterSet.decimalDigitCharacterSet(), intoString: nil)
        if scanner.scanInteger(&value) {
            print("did scan \(value)")
        }
        else {
            print("can't scan integer")
        }
        return value
    }

}