//
//  DishDetailViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 23/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit

class DishDetailViewController: UIViewController {
    @IBOutlet weak var recipeDescription: UITextView!
    @IBOutlet weak var ingredientsDescription: UITextView!
    @IBOutlet weak var makeDishButton: UIButton!
    @IBOutlet weak var forPersonsLabel: UILabel!
    var numberOfPersons = 0

    
    var dish: Dish?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup text views
        recipeDescription.editable = false
        recipeDescription.contentInset = UIEdgeInsetsMake(-5, 0, 0, 0)
        ingredientsDescription.editable = false
        ingredientsDescription.contentInset = UIEdgeInsetsMake(-5, 0, 0, 0)
        
        //Display the data from segue
        if let dish = dish {
            navigationItem.title = dish.name
            ingredientsDescription.text = generateIngredientsString(dish.ingredients)
            recipeDescription.text = dish.recipe
            
            var personsString = ""
            if numberOfPersons == 1 {
                personsString = "person"
            } else {
                personsString = "personer"
            }
            forPersonsLabel.text = "- til \(numberOfPersons) \(personsString) (originalt til \(dish.persons) personer)"
        }
        
        //Make find button a rounded rectangle
        let btnLayer = makeDishButton.layer
        btnLayer.masksToBounds = true
        btnLayer.cornerRadius = 5
    }
    
    //MARK: Formatting
    func generateIngredientsString(products: [Product]) -> String {
        var resultString = ""
        for p in products {
            let productWeightForPersons = (p.weight / dish!.persons) * numberOfPersons
            resultString += String(productWeightForPersons) + " " + p.unit.rawValue + " " + p.name + "\n"
        }
        return resultString
    }
    
    //MARK: Database manipulation
    @IBAction func makeDish(sender: AnyObject) {
        let database = loadProducts()
        
        //Subtracts the weight of the products in the dish from the DB
        if var DB = database {
            for dishProduct in dish!.ingredients {
                for databaseProduct in DB {
                    if dishProduct.name.lowercaseString == databaseProduct.name.lowercaseString {
                        let dishProductForPersonsWeight = (dishProduct.weight / dish!.persons) * numberOfPersons
                        databaseProduct.weight -= dishProductForPersonsWeight
                        
                        //remove product if weight is now 0
                        if databaseProduct.weight == 0 {
                            DB.removeObject(databaseProduct)
                        }
                    }
                }
            }
            saveProducts(DB)
            
            //Display message to user
            let alert = UIAlertController(title: "Held og Lykke!", message: "Ovenstående varer er fjernet fra køleskabet", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            makeDishButton.enabled = false
        }
    }
    
    //MARK: NSCoding
    func saveProducts(DB: [Product]) {
        let isSuccecfulSave = NSKeyedArchiver.archiveRootObject(DB, toFile: Product.ArchiveURL.path!)
        
        if !isSuccecfulSave {
            print("Failed to save products")
        }
    }
    
    func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Product.ArchiveURL.path!) as? [Product]
    }
}
