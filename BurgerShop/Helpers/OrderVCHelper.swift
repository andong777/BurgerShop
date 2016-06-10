//
//  OrderVCHelper.swift
//  BurgerShop
//
//  Created by andong on 16/5/5.
//  Copyright © 2016年 andong. All rights reserved.
//

import Foundation
import UIKit

class Stack<T> {
    var list = [T]()
    var count: Int { return list.count }
    func push(e: T) { list.append(e) }
    func pop() -> T? { return list.isEmpty ? nil : list.removeLast() }
    func peek() -> T? { return list.last }
    func isEmpty() -> Bool { return list.isEmpty }
}

class AbstractOrderViewController: UITableViewController {
    
    var item: OrderItem
    
    init(item: OrderItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.item = OrderItem.Bread
        super.init(coder: aDecoder)
    }
}

class OrderVCHelper {
    
    private let items = OrderItem.allValues
    private var pos = 0
    private var foodStack = Stack<FoodCount>()
    
    static let sharedInstance = OrderVCHelper()
    
    static let VC_ID = "OrderViewController"
    static let VC_ID_0 = "OrderViewControllerBread"
    
    private var options = [String]()
    
    private init() {
        
    }
    
    func getFirstVC(storyBoard: UIStoryboard) -> AbstractOrderViewController {
        while !foodStack.isEmpty() {
            foodStack.pop()
        }
//        return OrderViewController(item: items[pos])  // 被这里坑惨了
        let vc = storyBoard.instantiateViewControllerWithIdentifier(OrderVCHelper.VC_ID_0) as! OrderViewControllerBread
        vc.item = items[0]
        pos = 1
        return vc
    }
    
    func prepareForFirstVC() {
        while !foodStack.isEmpty() {
            foodStack.pop()
        }
        pos = 1
    }
    
    // 用于面包。只能有一个食物，数量为1
    func getNextVCAndRecord(food food: Food, storyBoard: UIStoryboard) -> AbstractOrderViewController? {
        foodStack.push((food: food, count: 1))
        var vc: OrderViewController?
        if pos < items.count {
            print("go to next order VC")
//            vc = OrderViewController(item: items[pos])
            vc = (storyBoard.instantiateViewControllerWithIdentifier(OrderVCHelper.VC_ID) as! OrderViewController)
            vc!.item = items[pos]
            pos += 1
        } else {
            print("no more order VC")
        }
        return vc
    }
    
    // 用于其他食物，可以选择多个，每个数量也可以有多个
    func getNextVCAndRecord(foodArray foodArray: [Food], countArray: [Int], storyBoard: UIStoryboard) -> AbstractOrderViewController? {
        for i in 0..<foodArray.count {
            foodStack.push((food: foodArray[i], count: countArray[i]))
        }
        var vc: OrderViewController?
        if pos < items.count {
            print("go to next order VC")
            //            vc = OrderViewController(item: items[pos])
            vc = (storyBoard.instantiateViewControllerWithIdentifier(OrderVCHelper.VC_ID) as! OrderViewController)
            vc!.item = items[pos]
            pos += 1
        } else {
            print("no more order VC")
        }
        return vc
    }
    
    func addOption(option: String) {
        options.append(option)
    }
    
    func removeOption(option: String) {
        for i in 0..<options.count {
            if options[i] == option {
                options.removeAtIndex(i)
                break
            }
        }
    }
    
    func goPrev() {
        foodStack.pop()
        pos -= 1
        if pos < 0 {
            pos = 0
        }
    }
    
    func getOrderDetailVC(storyBoard: UIStoryboard) -> OrderDetailViewController {
        print("go to order detail VC")
        let order = constructOrder()
        let vc = storyBoard.instantiateViewControllerWithIdentifier("OrderDetailViewController") as! OrderDetailViewController
        vc.order = order
        return vc
    }
    
    func constructOrder() -> Order {
        var foodArray = [Food]()
        var countArray = [Int]()
        while !foodStack.isEmpty() {
            if let foodCount = foodStack.pop() {
                foodArray.append(foodCount.food)
                countArray.append(foodCount.count ?? 1)
            }
        }
        let hamburger = Hamburger(foodArray: foodArray, countArray: countArray)
//        let price = foodArray.reduce(0) { $0 + $1.price }
        let price = hamburger.price
        let order = Order(hamburger: hamburger, price: price)
        
        // 写入备注
        order.options = options
        
        return order
    }
    
}