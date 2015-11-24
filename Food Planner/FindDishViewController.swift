//
//  ViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 19/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit

class FindDishViewController: UIViewController {
    
    @IBOutlet weak var dishResult: UILabel!
    
    var DB: [Product] = []
    var knownDishes = [Dish]()
    var resultDishes = [Dish]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //add standard dishes
        let ingredientsForPastaMeat = [Product(name: "pasta", weight: 100, unit: Unit.GRAM), Product(name: "oksekød", weight: 500, unit: Unit.GRAM), Product(name: "dolmio sovs", weight: 300, unit: Unit.GRAM)]
        let recipeForPastaMeat = " 1 - Brun oksekøddet \n2 - Hæld dolmiosovs i \n3 - Kog pasta \n4 - Spis"
        knownDishes.append(Dish(name: "Pasta med kødsovs", ingredients: ingredientsForPastaMeat, recipe: recipeForPastaMeat))
        
        let ingredientsForTestDish = [Product(name: "test1", weight: 100, unit: Unit.GRAM), Product(name: "test2", weight: 100, unit: Unit.GRAM)]
        let recipeForTestDish = "1 - sådan gør du først \n 2 - Så gør du sådan her \n 3 - så gør du sådan her"
        knownDishes.append(Dish(name: "TestMad", ingredients: ingredientsForTestDish, recipe: recipeForTestDish))
        
        if let savedProducts = loadProducts() {
            DB = savedProducts
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if let savedProducts = loadProducts() {
            DB = savedProducts
        }
    }
    
    //MARK: Algorithms
    @IBAction func findDish(sender: AnyObject) {
        //check if you have products and enough of them
        for dish in knownDishes {
            var isPossible = true
            for p in dish.ingredients {
                if !hasEnoughStuffOfProduct(p) {
                    isPossible = false
                }
            }
            
            if isPossible {
                resultDishes.append(dish)
            }
        }
        
        //Perform segue to detail view if resultDishes is non-empty
        if resultDishes.count > 0 {
            performSegueWithIdentifier("FindDish", sender: nil)
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
    
    //subtracts the weight of the products in the dish from the DB
    func removeDishProductsFromDB(dish: Dish) {
        for dishP in dish.ingredients {
            for fridgeP in DB {
                if dishP.name.lowercaseString == fridgeP.name.lowercaseString {
                    fridgeP.weight -= dishP.weight
                }
            }
        }
        saveProducts()
    }
    
    //MARK: NSCoding
    func saveProducts() {
        let isSuccecfulSave = NSKeyedArchiver.archiveRootObject(DB, toFile: Product.ArchiveURL.path!)
        
        if !isSuccecfulSave {
            print("Failed to save products")
        }
    }
    
    func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Product.ArchiveURL.path!) as? [Product]
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FindDish" {
            let dishResultViewController = segue.destinationViewController as! SeachResultTableViewController
            dishResultViewController.resultDishes = resultDishes
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


