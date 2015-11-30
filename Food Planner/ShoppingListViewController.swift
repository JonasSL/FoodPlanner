//
//  ShoppingListViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 29/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import Foundation
import UIKit

class ShoppingListViewController: UITableViewController {
    
    var shoppingList = [ShoppingProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaceholderProducts()
        
    }
    
    func loadPlaceholderProducts() {
        let benJerryIs = ShoppingProduct(name: "Ben&Jerry", weight: 500, unit: Unit.GRAM, dateExpires: NSDate.init())
        let marabou = ShoppingProduct(name: "Marabou Daim", weight: 200, unit: Unit.GRAM, dateExpires: NSDate.init())
        let slik = ShoppingProduct(name: "Slik", weight: 200, unit: Unit.GRAM, dateExpires: NSDate.init())
        shoppingList.append(benJerryIs)
        shoppingList.append(marabou)
        shoppingList.append(slik)
        tableView.reloadData()
    }
    
    //MARK: UITableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ShoppingListCell
        
        let product = shoppingList[indexPath.row]
        cell.nameLabel.text = product.name
        cell.weightLabel.text = String(product.weight) + " \(product.unit.rawValue)"
        
        if product.hasFound {
            cell.backgroundColor = UIColor.greenColor()
        } else {
            cell.backgroundColor = nil
        }
        
        return cell
        
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        shoppingList[indexPath.row].hasFound = !shoppingList[indexPath.row].hasFound
        /*shoppingList.sortInPlace() {
            $0.hasFound != $1.hasFound
        }*/
        tableView.reloadData()
    }
    
    
    //MARK: NSCoding
    func saveProducts() {
        let isSuccecfulSave = NSKeyedArchiver.archiveRootObject(shoppingList, toFile: Product.ArchiveURLShopping.path!)
        if !isSuccecfulSave {
            print("Failed to save products")
        }
    }
    
    func loadProducts() -> [ShoppingProduct]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Product.ArchiveURLShopping.path!) as? [ShoppingProduct]
    }

}
