//
//  DetailViewController.swift
//  Food Planner
//
//  Created by Jonas Larsen on 23/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//
import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var weightUnitLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let product = product {
            navigationItem.title = "Detaljer"
            nameLabel.text = product.name
            weightUnitLabel.text = String(product.weight) + " " + product.unit.rawValue
        }
    }

}
