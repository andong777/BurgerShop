//
//  ResultViewController.swift
//  BurgerShop
//
//  Created by 安东 on 16/5/5.
//  Copyright © 2016年 andong. All rights reserved.
//

import UIKit

class OrderDetailViewController: UITableViewController {
    
    var order: Order!
    var userType: UserType
    private let items = OrderItem.allValues
    
    // 用于从主厨推荐线路过来
    var recommendInfo: RecommendInfo?
    
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    init(order: Order, userType: UserType) {
        self.order = order
        self.userType = UserType.Customer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.userType = UserType.Customer
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch userType {
        case .Customer:
            confirmButton.title = "下单"
        case .Cook:
            confirmButton.title = "确认订单"
        case .Waiter:
            confirmButton.title = "完成订单"
        default:
            confirmButton.title = "逗你玩"
        }
        
        // 首先判断推荐信息是否存在
        if let recInfo = recommendInfo {
            NetworkHelper.getRecommendDetail(recInfo, completionHandler: handleRequestComplete, errorHandler: handleRequestFailed)
        } else if order.hamburger == nil && order.id != nil {  // 否则说明是下单过程，已经有食材信息了
            // 获取汉堡内容
            NetworkHelper.getOrderDetail(order, completionHandler: handleRequestComplete, errorHandler: handleRequestFailed)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRequestComplete(order: Order) {
        self.order = order
        tableView.reloadData()
    }
    
    func handleRequestFailed(error: NSError?) {
        // TODO
    }
    
    func handleUploadRequestComplete() {
        performSegueWithIdentifier("ShowResult", sender: self)
    }
    
    func handleUploadRequestFailed(error: NSError?) {
        
    }
    
    @IBAction func confirmButtonClicked(sender: AnyObject) {
        // 进行确认
        let alert = UIAlertController(title: "确认", message: "是否确定“\(confirmButton.title ?? "")”", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "取消", style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (action: UIAlertAction!) in
            print("action")
            if self.userType == UserType.Customer {
                NetworkHelper.submitOrder(self.order, completionHandler: self.handleUploadRequestComplete, errorHandler: self.handleUploadRequestFailed)
            } else if self.userType == UserType.Cook {
                NetworkHelper.updateOrder(self.order, toState: .Confirmed, completionHandler: self.handleUploadRequestComplete, errorHandler: self.handleUploadRequestFailed)
            } else if self.userType == UserType.Waiter {
                NetworkHelper.updateOrder(self.order, toState: .Finished, completionHandler: self.handleUploadRequestComplete, errorHandler: self.handleUploadRequestFailed)
            }
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let order = order, burger = order.hamburger {
                return burger.foodCountArray.count + 1  // 增加备注信息
            } else {
                return 0
            }
        } else {
            if let order = order, state = order.state {
                switch state {
                case .Waiting:
                    return 1
                case .Ordered:
                    return 2
                case .Confirmed:
                    return 3
                case .Finished:
                    return 4
                default:
                    return 1
                }
            } else {
                return 0
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let index = indexPath.row
        if section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("OrderFoodItemIdentifier", forIndexPath: indexPath)
            if index == order.hamburger!.foodCountArray.count {
                // 显示备注信息
                cell.textLabel?.text = "备注"
                cell.detailTextLabel?.text = "；".join(order.options)
            } else {
                let foodItem = order.hamburger!.foodCountArray[index]
                let food = foodItem.food
                cell.textLabel?.text = food.name
                cell.detailTextLabel?.text = "\(food.price) 元 × \(Int(foodItem.count!))"
            }
            return cell
        } else {
            let text: String
            let cell = tableView.dequeueReusableCellWithIdentifier("OrderInfoItemIdentifier", forIndexPath: indexPath)
            switch index {
            case 0:
                text = "合计：\(order.price!) 元"
            case 1:
                let df = NSDateFormatter()
                df.timeZone = NSTimeZone.localTimeZone()
                df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let timeString = df.stringFromDate(order.time!)
                text = "订单创建于\(timeString)"
            case 2:
                text = "订单已由厨师 张三 确认"
            case 3:
                text = "订单已由服务员 李四 完成"
            default:
                text = ""
            }
            cell.textLabel!.text = text
            return cell
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? OrderResultViewController {
            vc.userType = userType
        }
    }

}
