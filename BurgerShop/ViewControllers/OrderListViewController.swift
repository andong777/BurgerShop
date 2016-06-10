//
//  OrderListViewController.swift
//  BurgerShop
//
//  Created by 安东 on 16/5/5.
//  Copyright © 2016年 andong. All rights reserved.
//

import UIKit

class OrderListViewController: UITableViewController {
    
    var userType: UserType
    private var orderArray = [Order]()
    
    init(userType: UserType) {
        self.userType = userType
        super.init(nibName: nil, bundle: nil)
    }
    
    init() {
        userType = UserType.Customer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        userType = UserType.Customer
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = false
        
        switch userType {
        case .Cook:
            title = "待处理订单"
        case .Waiter:
            title = "待完成订单"
        case .Administrator:
            title = "已完成订单"
        default:
            title = "你是怎么进来的？！"
        }
        
        // 下拉刷新
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
//        tableView.addSubview(refreshControl!)
    }
    
    override func viewWillAppear(animated: Bool) {
        refresh(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender: AnyObject) {
        // 查询服务器，获取相应订单数据
        NetworkHelper.getOrderList(user: userType, completionHandler: handleRequestComplete, errorHandler: handleRequestFailed)
    }
    
    func handleRequestComplete(data: [Order]) {
        refreshControl?.endRefreshing()
        orderArray = data
        tableView.reloadData()
    }
    
    func handleRequestFailed(error: NSError?) {
        // TODO
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let order = orderArray[indexPath.row]
//        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "OrderItemCell")
        let cell = tableView.dequeueReusableCellWithIdentifier("OrderItemCell", forIndexPath: indexPath)
        cell.textLabel?.text = "#\(order.id!)"
        let df = NSDateFormatter()
        df.timeZone = NSTimeZone.localTimeZone()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeString = df.stringFromDate(order.time!)
        cell.detailTextLabel?.text = "\(timeString)"
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let index = self.tableView.indexPathForSelectedRow!.row
        if let vc = segue.destinationViewController as? OrderDetailViewController {
            vc.order = orderArray[index]
            vc.userType = userType
        }
    }

}
