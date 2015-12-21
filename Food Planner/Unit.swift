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
    case SPSK = "spsk"
    case FED = "fed"
    case TSK = "tsk"
    
    static let allUnits = [GRAM,STK,L,ML,DL,SPSK,FED,TSK]
}
