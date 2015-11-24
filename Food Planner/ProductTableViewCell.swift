//
//  ProductTableViewCell.swift
//  Food Planner
//
//  Created by Jonas Larsen on 24/11/2015.
//  Copyright © 2015 JonasLarsen. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    @IBOutlet weak var nameCellLabel: UILabel!
    @IBOutlet weak var weightCellLabel: UILabel!
    @IBOutlet weak var daysRemainingCellLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
