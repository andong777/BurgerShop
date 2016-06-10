//
//  OrderResultViewController.swift
//  BurgerShop
//
//  Created by 安东 on 16/5/11.
//  Copyright © 2016年 andong. All rights reserved.
//

import UIKit

class OrderResultViewController: UIViewController {
    
    var userType: UserType

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hintLabel: UITextView!
    
    required init?(coder aDecoder: NSCoder) {
        userType = UserType.Customer
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton: UIBarButtonItem
        if userType == UserType.Customer {
            titleLabel.text = "订单提交成功！"
            backButton = UIBarButtonItem(title: "返回首页", style: .Plain, target: self, action: #selector(goHome(_:)))
            
        } else {
            titleLabel.text = "订单更新成功！"
            backButton = UIBarButtonItem(title: "返回", style: .Plain, target: self, action: #selector(goBack(_:)))
            hintLabel.hidden = true
        }
        
        navigationItem.leftBarButtonItem = backButton;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goHome(sender: UIBarButtonItem) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func goBack(sender: UIBarButtonItem) {
        if let vc = navigationController?.viewControllers[1] {
            navigationController?.popToViewController(vc, animated: true)
        }
    }

}
