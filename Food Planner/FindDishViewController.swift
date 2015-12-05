//
//  ViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 19/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit
import Parse

class FindDishViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
        
    var DB: [Product] = []
    var knownDishes = [Dish]()
    var resultDishes = [Dish]()
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var personPickerView: UIPickerView!
    var pickerData: [Int] = [1,2,3,4,5,6,7,8,9,10]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //Get dishes from Parse DB
        knownDishes = getDishesFromServer()
        //uploadSampleDishes()
        
        //Load the products from the DB
        if let savedProducts = loadProducts() {
            DB = savedProducts
        }
        
        //Set delegate
        personPickerView.delegate = self
        
        //Make find button a rounded rectangle
        let btnLayer = findButton.layer
        btnLayer.masksToBounds = true
        btnLayer.cornerRadius = 5
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if let savedProducts = loadProducts() {
            DB = savedProducts
        }
        resultDishes = []
        navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
    //MARK: Algorithms
    @IBAction func findDish(sender: AnyObject) {
        //Reset resultDishes
        resultDishes = []
        
        //check if you have products and enough of them
        for dish in knownDishes {
            var isPossible = true
            for p in dish.ingredients {
                if !hasEnoughStuffOfProduct(p, dishForPersons: dish.persons) {
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
            alert.addAction(UIAlertAction(title: "Forslag", style: .Default, handler: { (action: UIAlertAction!) -> () in self.performSegueWithIdentifier("NeedHelp", sender: self) } ))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }

    //checks if the product is in the DB and if
    func hasEnoughStuffOfProduct(product: Product, dishForPersons: Int) -> Bool {
        var isPossible = false
        for p in DB {
            //Find weight of ingredient for number of persons picked
            let productWeightForPersons = (product.weight / dishForPersons) * pickerData[personPickerView.selectedRowInComponent(0)]
            if p == product && p.weight >= productWeightForPersons && p.unit == product.unit {
                isPossible = true
            }
        }
        return isPossible
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
            //Send the picked number of person to SeachResultTableViewController
            dishResultViewController.numberOfPersons = pickerData[personPickerView.selectedRowInComponent(0)]
        } else if segue.identifier == "NeedHelp" {
            let dishSuggestionViewController = segue.destinationViewController as! SuggestionViewController
            dishSuggestionViewController.knownDishes = knownDishes
            dishSuggestionViewController.products = DB
            dishSuggestionViewController.persons = pickerData[personPickerView.selectedRowInComponent(0)]
        }
    }
    
    // MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(stringInterpolationSegment: pickerData[row])
    }
    
    // MARK: Parse database
    func uploadSampleDishes() {
        //Pasta med kødsovs
        let recipeForPastaMeat = " 1 - Brun oksekøddet \n2 - Hæld dolmiosovs i \n3 - Kog pasta \n4 - Spis"
        let namePasta = "Pasta med kødsovs"
        let personsPasta = 2
        let ingredientsPasta = [["Pasta","100","g"],["Oksekød","500","g"],["Dolmio Sovs","300","g"]]
        
        let pastaDish = PFObject(className: "Dishes")
        pastaDish["name"] = namePasta
        pastaDish["ingredients"] = ingredientsPasta
        pastaDish["persons"] = personsPasta
        pastaDish["recipe"] = recipeForPastaMeat
        pastaDish.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            print("Object has been saved.")
        }
        
        //TestMad
        let recipeForTestDish = "1 - sådan gør du først \n2 - Så gør du sådan her \n3 - så gør du sådan her"
        let nameTest = "TestMad"
        let personsTest = 4
        let ingredientsTest = [["test1","100","g"],["test2","100","g"]]
        
        let testDish = PFObject(className: "Dishes")
        testDish["name"] = nameTest
        testDish["ingredients"] = ingredientsTest
        testDish["persons"] = personsTest
        testDish["recipe"] = recipeForTestDish
        testDish.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            print("Object has been saved.")
        }
    }
    
    func getDishesFromServer() -> [Dish] {
        var result = [Dish]()
        
        let query = PFQuery(className:"Dishes")
        var objects = [PFObject]()
        
        do {
            objects = try query.findObjects()
        } catch {
            print("Couldn't get objects from Parse")
        }
        
        for dish in objects {
            let dishName = dish["name"] as! String
            let dishRecipe = dish["recipe"] as! String
            let dishPersons = dish["persons"] as! Int
            
            var dishIngredients = [Product]()
            
            let allIngredients = dish["ingredients"] as! [[String]]
            print(allIngredients)
            
            for ingredients in allIngredients {
                //1st element is name, 2nd is weight, 3rd is rawvalue of unit
                let productName = ingredients[0]
                let productWeight = Int(ingredients[1])!
                let productUnit = Unit(rawValue: ingredients[2])!
                
                let newProduct = Product(name: productName, weight: productWeight, unit: productUnit, dateExpires: NSDate.init())
                dishIngredients.append(newProduct)
            }
            
            let newDish = Dish(name: dishName, ingredients: dishIngredients, recipe: dishRecipe, persons: dishPersons)
            result.append(newDish)
        }
        
        print(result)
        return result
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


