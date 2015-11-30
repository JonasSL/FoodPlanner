//
//  SuggestionViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 26/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit

class SuggestionViewController: UIViewController {
    @IBOutlet weak var name1Label: UILabel!
    @IBOutlet weak var name2Label: UILabel!
    @IBOutlet weak var ingredients1TextView: UITextView!
    @IBOutlet weak var ingredients2TextView: UITextView!
    @IBOutlet weak var forPersonsLabel: UILabel!
    @IBOutlet weak var originalPersons1Label: UILabel!
    @IBOutlet weak var originalPersons2Label: UILabel!

    var products = [Product]()
    var knownDishes = [Dish]()
    var suggestionDishes = [Dish]()
    var subtractedWeight = [Product: Int]()
    var shoppingList = [ShoppingProduct]()
    var persons = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findSuggestions()
        
        //Show results
        name1Label.text = knownDishes[0].name
        name2Label.text = knownDishes[1].name
        ingredients1TextView.text = generateIngredientsString(knownDishes[0].ingredients)
        ingredients2TextView.text = generateIngredientsString(knownDishes[1].ingredients)
        
        var personsString = ""
        if persons == 1 {
            personsString = "person"
        } else {
            personsString = "personer"
        }
        forPersonsLabel.text = "Til \(persons) " + personsString
        originalPersons1Label.text = "(originalt til \(knownDishes[0].persons) personer)"
        originalPersons2Label.text = "(originalt til \(knownDishes[1].persons) personer)"

        //Load saved shoppingList
        if let savedShoppingList = loadProducts() {
            shoppingList = savedShoppingList
        }
    }

    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    
    //Find the best suggestions for dishes to make
    func findSuggestions() {
        /*
            Below we have to use another instance of a datastructure to store the subtracted weight, because suggestionDishes is just a shallow copy;
            it refenreces to the original Product-objects as we made when the Dish-object was defined. Because of that, the original recipe will be changed - and we don't want that.
        */
        
        //Subtract the weight of the products we have from the knownDishes and store them in the dictionary
        for dish in knownDishes {
            //Append empty array for the product weights to be in
            
            for dishProduct in dish.ingredients {
                //Find the weight of product needed for number of persons
                let dishProductForPersonsWeight = (dishProduct.weight / dish.persons) * persons
                
                for product in products {
                    if dishProduct.name.lowercaseString == product.name.lowercaseString {
                        subtractedWeight[dishProduct] = dishProductForPersonsWeight - product.weight
                        break
                    } else {
                        subtractedWeight[dishProduct] = dishProductForPersonsWeight
                    }
                }
                
                //Fill the array with original weight if products is empty - and therefore it doesn't get into the for loop
                if products.isEmpty {
                    subtractedWeight[dishProduct] = dishProductForPersonsWeight
                }
                
            }
        }
        
        //Sort the array so the first element is the one you need the least amount of products for
        knownDishes.sortInPlace() {
            (lhs,rhs) -> Bool in sortAccordingToTotalWeight(lhs, dish2: rhs)
        }
    }
    
    //MARK: Formatting
    func generateIngredientsString(products: [Product]) -> String {
        var resultString = ""
        for p in products {
            if subtractedWeight[p]! > 0 {
                resultString += String(subtractedWeight[p]!) + " " + p.unit.rawValue + " " + p.name + "\n"
            }
        }
        return resultString
    }
    
    
    
    func sortAccordingToTotalWeight(dish1: Dish, dish2: Dish) -> Bool {
        var sumWeight1 = 0
        var sumWeight2 = 0
        
        for product in dish1.ingredients {
            sumWeight1 += subtractedWeight[product]!
        }
        for product in dish2.ingredients {
            sumWeight2 += subtractedWeight[product]!
        }
        
        return sumWeight1 < sumWeight2
    }


    
    // MARK: - ShoppingList administration
    @IBAction func addDishToShoppingList(sender: AnyObject) {
        var message = ""
        var newProducts = [Product]()
        
        if sender.tag == 1 {
            newProducts = knownDishes[0].ingredients
            message = "Foreslag 1 er tilføjet indkøbslisten"
        } else {
            newProducts = knownDishes[1].ingredients
            message = "Foreslag 2 er tilføjet indkøbslisten"
        }
        
        for product in newProducts {
            //Only add product ingredient if the subtracted weight is positive (dont add things you dont need)
            if subtractedWeight[product]! > 0 {
                let shoppingProduct = ShoppingProduct(name: product.name, weight: subtractedWeight[product]!, unit: product.unit, dateExpires: product.dateExpires)
                shoppingList.append(shoppingProduct)
            }
        }
        
        let alert = UIAlertController(title: "Indkøbsliste", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        saveProducts()
    }
    
    
    //MARK: NSCoding
    func saveProducts() {
        let isSuccecfulSave = NSKeyedArchiver.archiveRootObject(shoppingList, toFile: ShoppingProduct.ArchiveURLShopping.path!)
        if !isSuccecfulSave {
            print("Failed to save products")
        } else {
            print("Save succesful")
        }
    }
    
    func loadProducts() -> [ShoppingProduct]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(ShoppingProduct.ArchiveURLShopping.path!) as? [ShoppingProduct]
    }

}
