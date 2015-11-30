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
    var dateAdded: NSDate
    var dateExpires: NSDate
    var daysToExpiration: Int
    
    init(name: String, weight: Int, unit: Unit, dateExpires: NSDate) {
        self.name = name
        self.weight = weight
        self.unit = unit
        self.dateAdded = NSDate.init()
        self.dateExpires = dateExpires
        
        //Find days remaining of product
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day], fromDate: dateAdded, toDate: self.dateExpires, options: [])
        daysToExpiration = components.day
        super.init()
        

    }
    
    func daysBetweenDate(startDate: NSDate, endDate: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day], fromDate: startDate, toDate: endDate, options: [])
        return components.day
    }
    
    //MARK: Properties
    struct PropertyKey {
        static let nameKey = "name"
        static let weightKey = "weight"
        static let unitKey = "unit"
        static let dateAddedKey = "dateAdded"
        static let dateExpiresKey = "dateExpires"
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("DB")
    static let ArchiveURLShopping = DocumentsDirectory.URLByAppendingPathComponent("ShoppingList")
    
    //MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeInteger(weight, forKey: PropertyKey.weightKey)
        aCoder.encodeObject(unit.rawValue, forKey: PropertyKey.unitKey)
        aCoder.encodeObject(dateAdded, forKey: PropertyKey.dateAddedKey)
        aCoder.encodeObject(dateExpires, forKey: PropertyKey.dateExpiresKey)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let weight = aDecoder.decodeIntegerForKey(PropertyKey.weightKey)
        let unitRaw = aDecoder.decodeObjectForKey(PropertyKey.unitKey) as! String
        let dateAddedStored = aDecoder.decodeObjectForKey(PropertyKey.dateAddedKey) as! NSDate
        let dateExpiresStored = aDecoder.decodeObjectForKey(PropertyKey.dateExpiresKey) as! NSDate
    
        self.init(name: name, weight: weight, unit: Unit(rawValue: unitRaw)!, dateExpires: dateExpiresStored)
        dateAdded = dateAddedStored
    }

}


func ==(lhs: Product, rhs: Product) -> Bool{
    let areEqual = lhs.name.lowercaseString == rhs.name.lowercaseString
    return areEqual
}