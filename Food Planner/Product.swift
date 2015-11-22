//
//  Product.swift
//  Food Planner
//
//  Created by Jonas Larsen on 19/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import Foundation

class Product: NSObject, NSCoding {
    var name: String
    var weight: Int
    var unit: Unit
    
    init(name: String, weight: Int, unit: Unit) {
        self.name = name
        self.weight = weight
        self.unit = unit
        
        super.init()
    }
    
    //MARK: Properties
    struct PropertyKey {
        static let nameKey = "name"
        static let weightKey = "weight"
        static let unitKey = "unit"
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("DB")
    
    //MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeInteger(weight, forKey: PropertyKey.weightKey)
        aCoder.encodeObject(unit.rawValue, forKey: PropertyKey.unitKey)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let weight = aDecoder.decodeIntegerForKey(PropertyKey.weightKey)
        let unitRaw = aDecoder.decodeObjectForKey(PropertyKey.unitKey) as! String
        
        self.init(name: name, weight: weight, unit: Unit(rawValue: unitRaw)!)
        
    }

}


func ==(lhs: Product, rhs: Product) -> Bool{
    let areEqual = lhs.name.lowercaseString == rhs.name.lowercaseString
    return areEqual
}