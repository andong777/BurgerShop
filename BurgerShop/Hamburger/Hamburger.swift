//
//  Hamburger.swift
//  BurgerShop
//
//  Created by 安东 on 16/5/3.
//  Copyright © 2016年 andong. All rights reserved.
//

import Foundation

class Hamburger {
//    var foodArray: [Food]!    // food that is not nil
//    var countArray: [Int]?
    var foodCountArray: [FoodCount]!
    
    var price: Double {
        get {
            var sumPrice = 0.0
            for i in 0..<foodCountArray.count {
                let foodCnt = foodCountArray[i]
                sumPrice += foodCnt.food.price * Double(foodCnt.count ?? 1)
            }
            return sumPrice
        }
    }
    
    // the initializers make sure that count > 0.
    init(foodArray: [Food]) {
        self.foodCountArray = foodArray.map { FoodCount(food: $0, count: 1) }
    }
    
    init(foodArray: [Food], countArray: [Int]) {
        self.foodCountArray = [FoodCount]()
        for i in 0..<foodArray.count {
            let foodCnt = FoodCount(food: foodArray[i], count: countArray[i])
            if foodCnt.count > 0 {
                self.foodCountArray.append(foodCnt)
            }
        }
    }
    
    init(foodCountArray: [FoodCount]) {
        self.foodCountArray = foodCountArray.filter { $0.count > 0 }
    }
    
    init() {
        
    }

}
