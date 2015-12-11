//
//  DishDetailWebViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 11/12/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit
import WebKit

class DishDetailWebViewController: UITableViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var dish: Dish?
    var numberOfPersons = 0
    var sendButton: UIBarButtonItem?
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton = UIBarButtonItem(title: "Jeg laver det!", style: UIBarButtonItemStyle.Plain, target: self, action: "makeDish")
        self.navigationItem.rightBarButtonItem = sendButton
        
        if let dish = dish {
            let url = NSURL(string: "http://www.dk-kogebogen.dk/opskrifter/visopskrift.php?id=28546&utm_source=foodPlanner&utm_medium=ios&utm_campaign=recipes")!
            webView.loadRequest(NSURLRequest(URL: url))
            webView.allowsBackForwardNavigationGestures = true
            
            navigationItem.title = dish.name
        }
    }
    
    func makeDish() {
        let database = loadProducts()
        
        //Make button disabled
        sendButton!.enabled = false
        
        //Subtracts the weight of the products in the dish from the DB
        if var DB = database {
            for dishProduct in dish!.ingredients {
                for databaseProduct in DB {
                    if dishProduct.name.lowercaseString == databaseProduct.name.lowercaseString {
                        // Dont use persons calculation
                        //let dishProductForPersonsWeight = (dishProduct.weight / dish!.persons) * numberOfPersons
                        databaseProduct.weight -= dishProduct.weight
                        
                        //remove product if weight is now 0
                        if databaseProduct.weight == 0 {
                            DB.removeObject(databaseProduct)
                        }
                    }
                }
            }
            saveProducts(DB)
            
            //Display message to user
            let alert = UIAlertController(title: "Held og Lykke!", message: "Varerne er fjernet fra køleskabet", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    //MARK: NSCoding
    func saveProducts(DB: [Product]) {
        let isSuccecfulSave = NSKeyedArchiver.archiveRootObject(DB, toFile: Product.ArchiveURL.path!)
        
        if !isSuccecfulSave {
            print("Failed to save products")
        }
    }
    
    func loadProducts() -> [Product]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Product.ArchiveURL.path!) as? [Product]
    }
    
}
