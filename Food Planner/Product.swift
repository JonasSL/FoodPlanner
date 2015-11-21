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
    
    init(type: String, weight: Int) {
        self.type = type
        self.weight = weight
    }
    
}

extension Product: Equatable {}

func ==(lhs: Product, rhs: Product) -> Bool{
    let areEqual = lhs.type.lowercaseString == rhs.type.lowercaseString
    return areEqual
}