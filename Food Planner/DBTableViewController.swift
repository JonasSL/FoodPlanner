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
    
    //MARK: Initialisation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load any saved products
        if let savedProducts = loadProducts() {
            DB = savedProducts
        }
        
        //Add edit button
        navigationItem.leftBarButtonItem = editButtonItem()
        
        //Remove empty cells
        let tblView = UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView?.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        if let savedProducts = loadProducts() {
            DB = savedProducts
        }
        DB.sortInPlace() {
            $0.daysToExpiration < $1.daysToExpiration
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: UITableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ProductTableViewCell
        cell.nameCellLabel?.text = DB[indexPath.row].name
        cell.weightCellLabel?.text = String(stringInterpolationSegment: DB[indexPath.row].weight) + " " + DB[indexPath.row].unit.rawValue
        
        let days = DB[indexPath.row].daysToExpiration
        var daysRemainingString = " dage tilbage"
        if days == 1 {
            daysRemainingString = " dag tilbage"
        } else if days == -1 {
            daysRemainingString = " dag for gammel"
        } else if days < -1 {
            daysRemainingString = " dage for gammel"
        }
        cell.daysRemainingCellLabel?.text = String(abs(days)) + daysRemainingString
        
        //Edit the label color
        if days <= 2 {
            //Red
            cell.daysRemainingCellLabel.textColor = UIColor(colorLiteralRed: 0.80, green: 0.00, blue: 0.00, alpha: 1.0)
        } else if days <= 5 {
            //Yellow
            cell.daysRemainingCellLabel.textColor = UIColor(colorLiteralRed: 1.00, green: 0.85, blue: 0.40, alpha: 1.0)
        } else {
            //Black
            cell.daysRemainingCellLabel.textColor = UIColor(colorLiteralRed: 0.00, green: 0.00, blue: 0.00, alpha: 1.0)
        }
        
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
    //add product from AddProductTableViewController to DB and insert row if it is a new product
    @IBAction func unwwindToProductList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? AddProductTableViewController, product = sourceViewController.product {
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
            let productDetailViewController = segue.destinationViewController as! ProductDetailViewController
            if let selectedProductCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(selectedProductCell)!
                let selectedProduct = DB[indexPath.row]
                productDetailViewController.product = selectedProduct
                
            }
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
