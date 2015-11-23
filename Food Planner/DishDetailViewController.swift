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
        }
    }
    
    //MARK: Formatting
    func generateIngredientsString(products: [Product]) -> String {
        var resultString = ""
        for p in products {
            resultString += String(p.weight) + " " + p.unit.rawValue + " " + p.name + "\n"
        }
        return resultString
    }
}
