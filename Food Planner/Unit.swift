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
    case STK = "stk"
    case L = "l"
    case ML = "ml"
    case DL = "dl"
    
    static let allUnits = [GRAM,STK,L,ML,DL]
}
