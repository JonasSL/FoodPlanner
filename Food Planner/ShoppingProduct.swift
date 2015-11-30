//
//  ShoppingProduct.swift
//  Food Planner
//
//  Created by Jonas Larsen on 29/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import Foundation

class ShoppingProduct: Product {
    var hasFound = false
    
    override init(name: String, weight: Int, unit: Unit, dateExpires: NSDate) {
        super.init(name: name, weight: weight, unit: unit, dateExpires: dateExpires)
    }
}
