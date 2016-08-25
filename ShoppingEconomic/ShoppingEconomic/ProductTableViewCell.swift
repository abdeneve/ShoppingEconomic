//
//  ProductTableViewCell.swift
//  ShoppingEconomic
//
//  Created by Diego Alejandro Orellana Lopez on 8/23/16.
//  Copyright © 2016 Alex Salazar. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var imgPhoto: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
