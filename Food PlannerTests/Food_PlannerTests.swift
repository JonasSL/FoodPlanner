//
//  Food_PlannerTests.swift
//  Food PlannerTests
//
//  Created by Jonas Larsen on 19/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import XCTest
@testable import Food_Planner

class Food_PlannerTests: XCTestCase {
    var model = ViewController()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testProductsGoCorrectlyIntoDB() {
        let type = "rice"
        let product = Product(t: type)
        model.addProductToDB(product)
        XCTAssertEqual(product.type, model.DB[model.DB.count-1].type)
    }
    
    
    

    
    
}
