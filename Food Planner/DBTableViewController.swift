//
//  DBTableViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 21/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit
import Foundation

class DBTableViewController: UITableViewController {
    
    var DB: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load any saved products
        if let savedProducts = loadProducts() {
            DB = savedProducts
        }
        
        //Add edit button
        navigationItem.leftBarButtonItem = editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        //DB = SharingManager.sharedInstance.mainDB
        if let savedProducts = loadProducts() {
            DB = savedProducts
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: UITableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell!
        cell.textLabel?.text = DB[indexPath.row].name
        cell.detailTextLabel?.text = String(stringInterpolationSegment: DB[indexPath.row].weight) + " " + DB[indexPath.row].unit.rawValue
        return cell
        
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DB.count
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            DB.removeAtIndex(indexPath.row)
            saveProducts()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            //do something else
        }
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //MARK: Navigation
    //add product from AddViewController to DB and insert row if it is a new product
    @IBAction func unwwindToProductList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? AddViewController, product = sourceViewController.product {
            let newIndexPath = NSIndexPath(forRow: DB.count, inSection: 0)
            if addProductToDB(product) {
                //add product to table
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            } else {
                
                //reload the data
                tableView.reloadData()
            }
            
            //update the shared DB
            saveProducts()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let productDetailViewController = segue.destinationViewController as! DetailViewController
            if let selectedProductCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(selectedProductCell)!
                let selectedProduct = DB[indexPath.row]
                productDetailViewController.product = selectedProduct
                
            }
            
        } else if segue.identifier == "AddItem" {
            
        }
    }
    
    
    //MARK: DB Management
    //add the products to the database - return true if new product is added
    func addProductToDB(p: Product) -> Bool{
        var isIncluded = false
        for productFromDB in DB {
            if productFromDB == p && productFromDB.unit == p.unit{
                //add the weight from the new product to the existing product
                productFromDB.weight += p.weight
                
                isIncluded = true
                break
            }
        }
        if !isIncluded {
            DB.append(p)
            return true
        }
        return false
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
}
