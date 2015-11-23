//
//  SeachResultTableViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 23/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit

class SeachResultTableViewController: UITableViewController {
    var resultDishes = [Dish]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Resultater"
    
    }

    //MARK: UITableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell!
        cell.textLabel?.text = resultDishes[indexPath.row].name
        return cell
        
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultDishes.count
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDishDetail" {
            let dishDetailViewController = segue.destinationViewController as! DishDetailViewController
            if let selectedProductCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(selectedProductCell)!
                let selectedProduct = resultDishes[indexPath.row]
                dishDetailViewController.dish = selectedProduct
            }
            
        }
    }
    
}
