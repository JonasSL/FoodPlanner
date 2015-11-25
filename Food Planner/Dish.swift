//
//  Dish.swift
//  Food Planner
//
//  Created by Jonas Larsen on 19/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import Foundation

class Dish {
    var name: String
    var ingredients: [Product]
    var recipe: String
    var persons: Int
    
    init(name: String, ingredients: [Product], recipe: String, persons: Int) {
        self.name = name
        self.ingredients = ingredients
        self.recipe = recipe
        self.persons = persons
    }
}
