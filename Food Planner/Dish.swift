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
    var id: Int
    override var hashValue: Int {
        return name.hash + persons
    }
    
    init(name: String, ingredients: [Product], recipe: String, persons: Int, id: Int) {
        self.name = name
        self.ingredients = ingredients
        self.recipe = recipe
        self.persons = persons
       self.id = id
    }
    
    //MARK: Properties
    struct PropertyKey {
        static let nameKey = "name"
        static let ingredientsKey = "ingredients"
        static let recipeKey = "recipe"
        static let personsKey = "persons"
        static let idKey = "id"
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
        aCoder.encodeInteger(id, forKey: PropertyKey.idKey)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let ingredients = aDecoder.decodeObjectForKey(PropertyKey.ingredientsKey) as! [Product]
        let recipe = aDecoder.decodeObjectForKey(PropertyKey.recipeKey) as! String
        let persons = aDecoder.decodeIntegerForKey(PropertyKey.personsKey)
        let id = aDecoder.decodeIntegerForKey(PropertyKey.idKey)

        
        self.init(name: name, ingredients: ingredients, recipe: recipe, persons: persons,id: id)
    }

}


func ==(lhs: Dish, rhs: Dish) -> Bool{
    return lhs.name == rhs.name
}
