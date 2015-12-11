//
//  ProductDetailTableViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 05/12/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit

class ProductDetailTableViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var weightUnitLabel: UILabel!
    @IBOutlet weak var dateAddedLabel: UILabel!
    @IBOutlet weak var dateExpireLabel: UILabel!
    
    var product: Product?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //tableView.allowsSelection = false
        
        if let product = product {
            navigationItem.title = "Detaljer"
            nameLabel.text = product.name
            weightUnitLabel.text = String(product.weight) + " " + product.unit.rawValue
            
            //Display the date
            let formatter = NSDateFormatter()
            let danishFormat = NSDateFormatter.dateFormatFromTemplate("MMMMddyyyy", options: 0, locale: NSLocale(localeIdentifier: "da-DK"))
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            formatter.dateFormat = danishFormat
            
            let dateAddedString = formatter.stringFromDate(product.dateAdded)
            dateAddedLabel.text = dateAddedString
            
            let dateExpireString = formatter.stringFromDate(product.dateExpires)
            dateExpireLabel.text =  dateExpireString
        }
    }
    
    //Make all cell non-selectable except the safari seach cell
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.tag == 2 {
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
        } else {
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
    }
    
    //Open safari with a google seach if you press the seach cell
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if cell.tag == 2 {
            //Replace whitespace with + for correct URL
            let urlString = "https://www.google.dk/#q=" + (product?.name)!.stringByReplacingOccurrencesOfString(" ", withString: "+")
            
            if let url = NSURL(string: urlString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
}
