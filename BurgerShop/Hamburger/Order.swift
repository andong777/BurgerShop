//
//  Order.swift
//  BurgerShop
//
//  Created by 安东 on 16/5/3.
//  Copyright © 2016年 andong. All rights reserved.
//

import Foundation

class Order: JsonCompatible {
    
    var hamburger: Hamburger?
    var id: Int?
    var state: OrderState?
    var time: NSDate?
    var price: Double?
    
    var options = [String]()   // 需求变更：备注信息
    
    // locally-generated
    init(hamburger: Hamburger, price: Double) {
        self.hamburger = hamburger
        state = OrderState.Waiting
        time = NSDate()
        self.price = price
    }
    
    // fetched
    init(hamburger: Hamburger, id: Int, state: OrderState?, time: NSDate?) {
        self.hamburger = hamburger
        self.id = id
        self.state = state
        self.time = time
    }
    
    // order shown in list vc
    init(id: Int, state: OrderState?, time: NSDate?, price: Double?) {
        self.id = id
        self.state = state
        self.time = time
        self.price = price
    }
    
    required init?(json: String) {
        let jsonData = json.dataUsingEncoding(NSUTF8StringEncoding)
        do {
            let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as! [String: String]
            hamburger = Hamburger()
            state = OrderState.Waiting
        } catch let error as NSError {
            print("cannot initialize form json")
            print(error)
            return nil
        }
    }
    
    init() {

    }
    
    func addInfo(info: String) {
        self.options.append(info)
    }
}
