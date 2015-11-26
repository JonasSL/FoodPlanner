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

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
