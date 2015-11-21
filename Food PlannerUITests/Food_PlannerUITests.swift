//
//  Food_PlannerUITests.swift
//  Food PlannerUITests
//
//  Created by Jonas Larsen on 19/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import XCTest


class Food_PlannerUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
       XCUIApplication().launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testRecentlyAddedProductsAreDisplayed() {
       
        
        let app = XCUIApplication()
        XCTAssert(app.textFields["inputTextField"].exists)
        let textField = app.textFields["inputTextField"]
        textField.tap()
        textField.typeText("pizza")
        app.buttons["Tilfoj vare"].tap()

        
    }
}
