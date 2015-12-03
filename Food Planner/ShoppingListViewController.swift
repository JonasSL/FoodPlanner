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
        
        //Remove empty cells
        let tblView = UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView?.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        //Load saved shoppingList
        if let savedShoppingList = loadProducts() {
            shoppingList = savedShoppingList
        }
        tableView.reloadData()
    }
    
    //MARK: UITableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ShoppingListCell
        
        let product = shoppingList[indexPath.row]
        cell.nameLabel.text = product.name
        cell.weightLabel.text = String(product.weight) + " \(product.unit.rawValue)"
        
        if product.hasFound {
            cell.checkMark.hidden = false
        } else {
            cell.checkMark.hidden = true
        }
        
        return cell
        
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        emptyLabel.text = "Tilføj varer ved at tilføje foreslåede retter"
        emptyLabel.textAlignment = NSTextAlignment.Center
        self.tableView.backgroundView = emptyLabel
        if shoppingList.count == 0{
            emptyLabel.hidden = false
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        } else {
            emptyLabel.hidden = true
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            return 1
        }

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        shoppingList[indexPath.row].hasFound = !shoppingList[indexPath.row].hasFound
        tableView.reloadData()
    }
    
    
    //Clean up the list and remove the found products (green cells)
    @IBAction func removeFoundProducts(sender: AnyObject) {
        for product in shoppingList {
            if product.hasFound {
                shoppingList.removeObject(product)
            }
        }
        
        saveProducts()
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
