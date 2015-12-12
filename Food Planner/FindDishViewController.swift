//
//  ViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 19/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit
import Parse
import SystemConfiguration

class FindDishViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
        
    var DB: [Product] = []
    var knownDishes = [Dish]()
    var resultDishes = [Dish]()
    var lastUpdateDate: NSDate?
    
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var updateIcon: UIImageView!
    @IBOutlet weak var updateActivity: UIActivityIndicatorView!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var updateDishesButton: UIButton!
    
    @IBOutlet weak var personPickerView: UIPickerView!
    var pickerData: [Int] = [1,2,3,4,5,6,7,8,9,10]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Load the products from the DB
        if let savedProducts = loadProducts() {
            DB = savedProducts
        }
        
        //Load knownDishes from the DB
        if let savedDishes = loadDishes() {
            knownDishes = savedDishes
        }
        
        //Set delegate
        personPickerView.delegate = self
        
        //Make buttons rounded rectangles
        let btnLayer = findButton.layer
        btnLayer.masksToBounds = true
        btnLayer.cornerRadius = 5
        
        let btn2Layer = updateDishesButton.layer
        btn2Layer.masksToBounds = true
        btn2Layer.cornerRadius = 5
        
        //Set picker to start at 4 persons
        personPickerView.selectRow(3, inComponent: 0, animated: true)

        //Load date from DB
        lastUpdateDate = loadDate()
        updateLastUpdateLabel()
        
        let controller = DataController()
        controller.fetchDish()
        
        print("ran datacontroller")
    }
    
    override func viewWillAppear(animated: Bool) {
        if let savedProducts = loadProducts() {
            DB = savedProducts
        }
        resultDishes = []
        navigationController?.setNavigationBarHidden(true, animated: true)

        //Hide and stop activity indicator
        updateActivity.stopAnimating()
        
        //Set text and enable the update button
        updateDishesButton.setTitle("Opdater retter", forState: UIControlState.Normal)
        updateDishesButton.enabled = true

        //Set updateIcon invisible
        updateIcon.alpha = 0
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
    func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Product.ArchiveURL.path!) as? [Product]
    }
    
    func saveDishes() {
        let isSuccecfulSave = NSKeyedArchiver.archiveRootObject(knownDishes, toFile: Dish.ArchiveURL.path!)
        if !isSuccecfulSave {
            print("Failed to save knownDishes")
        }
    }
    
    func loadDishes() -> [Dish]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Dish.ArchiveURL.path!) as? [Dish]
    }
    
    func saveDate() {
        let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("lastUpdateDate")
        
        let isSuccecfulSave = NSKeyedArchiver.archiveRootObject(lastUpdateDate!, toFile: ArchiveURL.path!)
        if !isSuccecfulSave {
            print("Failed to save knownDishes")
        }
    }
    
    func loadDate() -> NSDate? {
        let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("lastUpdateDate")

        return NSKeyedUnarchiver.unarchiveObjectWithFile(ArchiveURL.path!) as? NSDate
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
            let dishId = dish["webId"] as! Int
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
            
            let newDish = Dish(name: dishName, ingredients: dishIngredients, recipe: dishRecipe, persons: dishPersons, id: dishId)
            result.append(newDish)
        }
        
        print(result)
        return result
    }
    
    @IBAction func updateDishesPressed(sender: AnyObject) {
        //Fade in activity indicator and start the animation
        updateActivity.hidden = false
        updateActivity.alpha = 0

        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.updateActivity.alpha = 1
            self.updateDishesButton.setTitle("", forState: UIControlState.Normal)
        }, completion: nil)
        
        updateActivity.startAnimating()

        //Disable button
        updateDishesButton.enabled = false
        
        //Check if you are connected to the internet
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            updateIcon.image = UIImage(named: "HighPriorityRed-100")
        case .Online(.WWAN), .Online(.WiFi):
            //Get dishes from Parse DB
            knownDishes = getDishesFromServer()
            saveDishes()
            updateIcon.image = UIImage(named: "CheckmarkGreen-100")
        }

        //Hide activity indicator
        UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.updateActivity.alpha = 0
            }, completion: nil)
        
        //Show checkmark or warning
        UIView.animateWithDuration(1, delay: 0.8, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.updateIcon.alpha = 1
            }, completion: nil)
        
        lastUpdateDate = NSDate.init()
        updateLastUpdateLabel()
        saveDate()
    }
    
    private func formatDateWithTime(date: NSDate) -> String{
        let formatter = NSDateFormatter()
        //let danishFormat = NSDateFormatter.dateFormatFromTemplate("MMMMddyyyyHM", options: 0, locale: NSLocale(localeIdentifier: "da-DK"))
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        //formatter.dateFormat = danishFormat

        return formatter.stringFromDate(date)
    }
    
    private func updateLastUpdateLabel() {
        //Fade out label
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.lastUpdatedLabel.alpha = 0
            }, completion: nil)
        //Set lastUpdatedLabel to date, else tell to update
        if let date = lastUpdateDate {
            lastUpdatedLabel.text = "Sidst opdateret: " + formatDateWithTime(date)
        } else {
            lastUpdatedLabel.text = "Ingen data, tryk opdater"
        }
        
        //Fade in label
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.lastUpdatedLabel.alpha = 1
            }, completion: nil)
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





