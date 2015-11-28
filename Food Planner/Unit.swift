//
//  Unit.swift
//  Food Planner
//
//  Created by Jonas Larsen on 21/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import Foundation

enum Unit: String {
    case GRAM = "g"
    case KG = "kg"
    case STK = "stk"
    case L = "l"
    case ML = "ml"
    
    static let allUnits = [GRAM,KG,STK,L,ML]
}
