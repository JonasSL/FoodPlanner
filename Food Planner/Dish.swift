//
//  Dish.swift
//  Food Planner
//
//  Created by Jonas Larsen on 19/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import Foundation

class Dish: Hashable {
    var name: String
    var ingredients: [Product]
    var recipe: String
    var persons: Int
    var hashValue: Int {
        return name.hash + persons
    }
    
    init(name: String, ingredients: [Product], recipe: String, persons: Int) {
        self.name = name
        self.ingredients = ingredients
        self.recipe = recipe
        self.persons = persons
    }
}


func ==(lhs: Dish, rhs: Dish) -> Bool{
    return lhs.name == rhs.name
}
