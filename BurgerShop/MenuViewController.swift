//
//  ViewController.swift
//  BurgerShop
//
//  Created by 安东 on 16/5/3.
//  Copyright © 2016年 andong. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startOrder(sender: AnyObject) {
        let vc = OrderVCHelper.sharedInstance.getFirstVC(storyboard!)
        navigationController?.pushViewController(vc, animated: true)
        
//        if let vc = storyboard?.instantiateViewControllerWithIdentifier("OrderListViewController") as? OrderListViewController {
//            vc.userType = .Cook
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowOrder") {
            print("go to order")
        } else {
            let userType: UserType
            if segue.identifier == "ShowCookClient" {
                userType = .Cook
            } else if segue.identifier == "ShowWaiterClient" {
                userType = .Waiter
            } else {    // ShowAdministratorClient?
                userType = .Administrator
            }
            if let vc = segue.destinationViewController as? OrderListViewController {
                vc.userType = userType
            }
        }
    }
    
}
