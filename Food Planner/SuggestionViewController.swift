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

    var products: [Product] = []
    var knownDishes: [Dish] = []
    var suggestionDishes: [Dish] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findSuggestions()
        
        //Show results
        name1Label.text = suggestionDishes[0].name
        name2Label.text = suggestionDishes[1].name
        ingredients1TextView.text = generateIngredientsString(suggestionDishes[0].ingredients)
        ingredients2TextView.text = generateIngredientsString(suggestionDishes[1].ingredients)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //Find the best suggestions for dishes to make
    func findSuggestions() {
        //Assume that we dont have any products
        suggestionDishes = knownDishes
        
        //Subtract the weight of the products we have from the suggestions
        for dish in suggestionDishes {
            for dishProduct in dish.ingredients {
                for product in products {
                    if dishProduct.name.lowercaseString == product.name.lowercaseString {
                        //let dishProductForPersonsWeight = (dishProduct.weight / dish!.persons) * numberOfPersons
                        dishProduct.weight -= product.weight
                    }
                }
            }
        }
        
        //Sort the array so the first element is the one you need the least amount of products for
        suggestionDishes.sortInPlace() {
            (lhs,rhs) -> Bool in sortAccordingToTotalWeight(lhs, dish2: rhs)
        }
    }
    
    //MARK: Formatting
    func generateIngredientsString(products: [Product]) -> String {
        var resultString = ""
        for p in products {
            //let productWeightForPersons = (p.weight / dish!.persons) * numberOfPersons
            resultString += String(p.weight) + " " + p.unit.rawValue + " " + p.name + "\n"
        }
        return resultString
    }
    
    
    func sortAccordingToTotalWeight(dish1: Dish, dish2: Dish) -> Bool {
        var sumWeight1 = 0
        var sumWeight2 = 0
        
        for product in dish1.ingredients {
            sumWeight1 += product.weight
        }
        for product in dish2.ingredients {
            sumWeight2 += product.weight
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
