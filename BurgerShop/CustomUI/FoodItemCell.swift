//
//  FoodItemCell.swift
//  BurgerShop
//
//  Created by 安东 on 16/5/5.
//  Copyright © 2016年 andong. All rights reserved.
//

import UIKit

class FoodItemCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countButton: UIStepper!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func countChanged(sender: AnyObject) {
        countLabel.text = "\(Int(countButton.value))"
    }
}
