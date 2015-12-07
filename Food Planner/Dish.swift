//
//  Dish.swift
//  Food Planner
//
//  Created by Jonas Larsen on 19/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import Foundation

class Dish: NSObject, NSCoding {
    var name: String
    var ingredients: [Product]
    var recipe: String
    var persons: Int
    override var hashValue: Int {
        return name.hash + persons
    }
    
    init(name: String, ingredients: [Product], recipe: String, persons: Int) {
        self.name = name
        self.ingredients = ingredients
        self.recipe = recipe
        self.persons = persons
    }
    
    //MARK: Properties
    struct PropertyKey {
        static let nameKey = "name"
        static let ingredientsKey = "ingredients"
        static let recipeKey = "recipe"
        static let personsKey = "persons"
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("knownDishes")
    
    
    //MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(ingredients, forKey: PropertyKey.ingredientsKey)
        aCoder.encodeObject(recipe, forKey: PropertyKey.recipeKey)
        aCoder.encodeInteger(persons, forKey: PropertyKey.personsKey)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let ingredients = aDecoder.decodeObjectForKey(PropertyKey.ingredientsKey) as! [Product]
        let recipe = aDecoder.decodeObjectForKey(PropertyKey.recipeKey) as! String
        let persons = aDecoder.decodeIntegerForKey(PropertyKey.personsKey)
        
        self.init(name: name, ingredients: ingredients, recipe: recipe, persons: persons)
    }

}


func ==(lhs: Dish, rhs: Dish) -> Bool{
    return lhs.name == rhs.name
}
