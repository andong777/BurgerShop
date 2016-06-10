//
//  Food.swift
//  BurgerShop
//
//  Created by 安东 on 16/5/3.
//  Copyright © 2016年 andong. All rights reserved.
//

import Foundation

class Food: JsonCompatible {
    
    var id: Int
    var name: String = ""
    var price: Double = 0.0
    var imageUrl: String?
    
    var category: OrderItem?
    
    // 需求变更：营养成分
    var nutrition: [String: Double]?
    
    init(id: Int, name: String, price: Double, imageUrl: String?, nutrition: [String: Double]?) {
        self.id = id
        self.name = name
        self.price = price
        self.imageUrl = imageUrl
        self.nutrition = nutrition
    }
    
    convenience init(id: Int, name: String, price: Double, imageUrl: String?) {
        self.init(id: id, name: name, price: price, imageUrl: imageUrl, nutrition: nil)
    }
    
    // newly-created food
    init() {
        self.id = -1
    }
    
    required init?(json: String) {
        let jsonData = json.dataUsingEncoding(NSUTF8StringEncoding)
        do {
            let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as! [String: String]
            self.id = Int(jsonDict["food_detail_id"]!)!
            self.name = jsonDict["name"]!
            self.price = Double(jsonDict["price"]!)!
        } catch let error as NSError {
            print("cannot initialize form json")
            print(error)
            return nil
        }
    }
    
}

// 食物的子类，目前在代码中没有用到。
class Bread: Food { }

class Vegetable: Food { }

class Patty: Food { }

class Cheese: Food { }

class Sauce: Food { }

class Other: Food { }
