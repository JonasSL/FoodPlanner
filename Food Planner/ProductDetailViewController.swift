//
//  DetailViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 23/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//
import UIKit

class ProductDetailViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var weightUnitLabel: UILabel!
    @IBOutlet weak var dateExpireLabel: UILabel!
    @IBOutlet weak var dateAddedLabel: UILabel!
    
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            dateAddedLabel.text = "Tilføjet den " + dateAddedString
            
            let dateExpireString = formatter.stringFromDate(product.dateExpires)
            dateExpireLabel.text = "Bliver for gammel den " + dateExpireString
        }
    }
    

}
