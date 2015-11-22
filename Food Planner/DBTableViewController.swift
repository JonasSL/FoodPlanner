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
    
    var DB = SharingManager.sharedInstance.mainDB    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        DB = SharingManager.sharedInstance.mainDB
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell!
        cell.textLabel?.text = DB[indexPath.row].type
        cell.detailTextLabel?.text = String(stringInterpolationSegment: DB[indexPath.row].weight) + " " + DB[indexPath.row].unit.rawValue
        return cell
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DB.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //add product from AddViewController to DB and insert row if it is a new product
    @IBAction func unwwindToProductList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? AddViewController, product = sourceViewController.product {
            
            let newIndexPath = NSIndexPath(forRow: DB.count, inSection: 0)
            if addProductToDB(product) {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            } else {
                tableView.reloadData()
            }
            
            //update the shared DB
            SharingManager.sharedInstance.mainDB = DB
        }
    }
    
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
}
