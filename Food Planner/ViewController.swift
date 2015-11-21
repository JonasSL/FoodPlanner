//
//  ViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 19/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var dishResult: UILabel!
    @IBOutlet weak var inputWeight: UITextField!
    @IBOutlet weak var unitPicker: UIPickerView!
    
    var DB = SharingManager.sharedInstance.mainDB
    var knownDishes = [Dish]()
    let pickerData = Unit.allUnits

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        unitPicker.delegate = self
        unitPicker.dataSource = self
        
        //add standard dishes
        let ingredientsForPastaMeat = [Product(type: "pasta", weight: 100, unit: Unit.gram), Product(type: "oksekød", weight: 500, unit: Unit.gram), Product(type: "dolmio sovs", weight: 300, unit: Unit.gram)]
        let recipeForPastaMeat = "1 - Brun oksekøddet \n 2 - Hæld dolmiosovs i \n 3 - Kog pasta \n 4 - Spis"
        knownDishes.append(Dish(name: "Pasta med kødsovs", ingredients: ingredientsForPastaMeat, recipe: recipeForPastaMeat))
        
        let ingredientsForTestDish = [Product(type: "test1", weight: 100, unit: Unit.kg), Product(type: "test2", weight: 100, unit: Unit.kg)]
        let recipeForTestDish = "1 - sådan gør du først \n 2 - Så gør du sådan her \n 3 - så gør du sådan her"
        knownDishes.append(Dish(name: "TestMad", ingredients: ingredientsForTestDish, recipe: recipeForTestDish))
        
        
    }

    //picker setup
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].rawValue
    }
    
    //takes text from input field and adds it to DB
    @IBAction func addProduct(sender: AnyObject) {
        let product = Product(type: textField.text!, weight: Int(inputWeight.text!)!, unit: pickerData[unitPicker.selectedRowInComponent(0)])
        addProductToDB(product)
        textField.text = ""
        inputWeight.text = ""
        updateFridge()
    }
    
    @IBAction func findDish(sender: AnyObject) {
        /*
        (maybe used later)
        //make array with DB types
        var dbTypes = [String]()
        for p in DB {
            dbTypes.append(p.type.lowercaseString)
        }
        
        //find the dishes that you have ingredients for
        var possibleDishes = [Dish]()
        for dish in knownDishes {
            //make array with ingredient type
            var ingredientTypes = [String]()
            for ingredient in dish.ingredients {
                ingredientTypes.append(ingredient.type.lowercaseString)
            }
            
            var canMake = true
            for ingredient in ingredientTypes {
                if !(dbTypes.contains(ingredient)) {
                    canMake = false
                    break
                }
            }
            
            if canMake { possibleDishes.append(dish) }
        }
        */
        
        //check if you have products and enough of them
        var finalDishes = [Dish]()
        for dish in knownDishes {
            
            var isPossible = true
            for p in dish.ingredients {
                if !hasEnoughStuffOfProduct(p) {
                    isPossible = false
                }
            }
            
            if isPossible {
                finalDishes.append(dish)
            }
        }
        
        //display the first resulting dish - if any
        if finalDishes.count > 0 {
            dishResult.text = finalDishes[0].name + "\n" + finalDishes[0].recipe
            removeDishProductsFromDB(finalDishes[0])
            updateFridge()
        } else {
            //display error to user
            let alert = UIAlertController(title: "Fejl", message: "Du har ikke nok til at lave noget!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    //checks if the product is in the DB and if
    func hasEnoughStuffOfProduct(product: Product) -> Bool {
        var isPossible = false
        for p in DB {
            if p == product && p.weight >= product.weight && p.unit == product.unit {
                isPossible = true
            }
        }
        return isPossible
    }
    
    //add the products to the database
    func addProductToDB(p: Product) {
        
        var isIncluded = false
        for productFromDB in DB {
            if productFromDB == p && productFromDB.unit == p.unit{
                //add the weight from the new product to the existing product
                productFromDB.weight += p.weight
                
                isIncluded = true
                break
            }
        }
        
        if !isIncluded {
            DB.append(p)
        }
    }
    
    //updates the fridge label with contents of database
    func updateFridge() {
        SharingManager.sharedInstance.mainDB = DB
    }
    
    //subtracts the weight of the products in the dish from the DB
    func removeDishProductsFromDB(dish: Dish) {
        for dishP in dish.ingredients {
            for fridgeP in DB {
                if dishP.type.lowercaseString == fridgeP.type.lowercaseString {
                    fridgeP.weight -= dishP.weight
                }
            }
        }
    }
}


// Swift 2 Array Extension
extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}


