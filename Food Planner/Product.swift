//
//  Product.swift
//  Food Planner
//
//  Created by Jonas Larsen on 19/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import Foundation

class Product {
    var type: String
    var weight: Int
    var unit: Unit
    
    init(type: String, weight: Int, unit: Unit) {
        self.type = type
        self.weight = weight
        self.unit = unit
    }
    
}

extension Product: Equatable {}

func ==(lhs: Product, rhs: Product) -> Bool{
    let areEqual = lhs.type.lowercaseString == rhs.type.lowercaseString
    return areEqual
}