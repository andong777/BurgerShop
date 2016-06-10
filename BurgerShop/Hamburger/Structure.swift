//
//  Structure.swift
//  BurgerShop
//
//  Created by andong on 16/5/22.
//  Copyright © 2016年 andong. All rights reserved.
//

import Foundation

enum OrderItem: Int, CustomStringConvertible {
    case Bread = 1
    case Patty = 2
    case Vegetable = 3
    case Cheese = 4
    case Sauce = 5
    case Other = 6
    
    var description: String {
        switch self {
        case .Bread:
            return "面包"
        case .Patty:
            return "肉饼"
        case .Vegetable:
            return "蔬菜"
        case .Cheese:
            return "芝士"
        case .Sauce:
            return "酱料"
        case .Other:
            return "其他"
        }
    }
    
    static let allValues = [OrderItem.Bread, OrderItem.Patty, OrderItem.Vegetable, OrderItem.Cheese, OrderItem.Sauce, OrderItem.Other]
}

protocol JsonCompatible {
    init?(json: String);
}

enum UserType {
    case Customer
    case Cook
    case Waiter
    case Administrator
}

enum OrderState {
    case Waiting    // 等待下单
    case Ordered    // 已下单
    case Confirmed  // 已有厨师确认
    case Finished   // 已有服务器确认完成
    case Canceled   // 已取消
}

typealias RecommendInfo = (id: Int, image: String?, name: String?)
typealias FoodCount = (food: Food, count: Int?)
