//
//  FoodPropertyCell.swift
//  BurgerShop
//
//  Created by andong on 16/5/26.
//  Copyright © 2016年 andong. All rights reserved.
//

import UIKit

class FoodPropertyCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var input: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
