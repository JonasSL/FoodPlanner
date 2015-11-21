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
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
        cell.textLabel?.text = DB[indexPath.row].type
        cell.detailTextLabel?.text = String(stringInterpolationSegment: DB[indexPath.row].weight)
        return cell
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DB.count
    }
}
