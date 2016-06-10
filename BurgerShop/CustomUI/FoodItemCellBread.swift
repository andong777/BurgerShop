//
//  FoodItemCellBread.swift
//  BurgerShop
//
//  Created by andong on 16/5/22.
//  Copyright © 2016年 andong. All rights reserved.
//

import UIKit

class FoodItemCellBread: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
