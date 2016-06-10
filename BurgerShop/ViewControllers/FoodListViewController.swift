//
//  FoodListViewController.swift
//  BurgerShop
//
//  Created by andong on 16/5/25.
//  Copyright © 2016年 andong. All rights reserved.
//

import UIKit

class FoodListViewController: UITableViewController {
    
    let foodCategories = ["面包", "肉饼", "蔬菜", "芝士", "酱料", "其他"]
    var foodArrayInCategory = [Int: [Food]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = false

        // 下拉刷新
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        refresh(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender: AnyObject) {
        for i in 0..<6 {
            let orderItem = OrderItem.allValues[i]
            NetworkHelper.getFoodList(orderItem, completionHandler: handleRequestComplete, errorHandler: handleRequestFailed)
        }
    }
    
    func handleRequestComplete(data: [Food], categoryId: Int) {
        refreshControl?.endRefreshing()
        foodArrayInCategory[categoryId] = data
        tableView.reloadData()
    }
    
    func handleRequestFailed(error: NSError?) {
        // TODO
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return foodArrayInCategory.count    // how many categories
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodArrayInCategory[section + 1]?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FoodItemCell", forIndexPath: indexPath)

        let food = foodArrayInCategory[indexPath.section + 1]![indexPath.row]
        cell.textLabel?.text = food.name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return foodCategories[section]
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Create" {
            // vc.food is nil
        } else if segue.identifier == "Modify" {
            let indexPath = tableView.indexPathForSelectedRow!
            let food = foodArrayInCategory[indexPath.section + 1]![indexPath.row]
            food.category = OrderItem.allValues[indexPath.section]
            let vc = segue.destinationViewController as! FoodNutritionViewController
            vc.food = food
        }
    }

}
