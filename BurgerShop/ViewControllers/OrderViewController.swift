//
//  OrderViewController.swift
//  BurgerShop
//
//  Created by andong on 16/5/4.
//  Copyright © 2016年 andong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

let kSauceOptions = ["加盐", "加钙", "加蛋白粉"]

class OrderViewController: AbstractOrderViewController {

    var foodArray: [Food]!
    var countArray: [Int]!
    
    private var backButton: UIBarButtonItem!
    private var nextButton: UIBarButtonItem!

    private var hasSelectedItem = false {
        didSet {
            nextButton.enabled = hasSelectedItem
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = false
        
        backButton = UIBarButtonItem(title: "返回", style: .Plain, target: self, action: #selector(handleBack(_:)))
        navigationItem.leftBarButtonItem = backButton;
        
        nextButton = UIBarButtonItem(title: "下一步", style: .Plain, target: self, action: #selector(handleNext(_:)))
        navigationItem.rightBarButtonItem = nextButton

        title = item.description
        
        // 调用Web API，获取显示数据
        /* let req = Alamofire.request(.GET, "https://httpbin.org/get"); print(req) */
        NetworkHelper.getFoodList(item, completionHandler: handleRequestComplete, errorHandler: handleRequestFailed)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleBack(sender: UIBarButtonItem) {
        OrderVCHelper.sharedInstance.goPrev()
        navigationController?.popViewControllerAnimated(true)
    }
    
    func handleNext(sender: UIBarButtonItem) {
        if let vc = OrderVCHelper.sharedInstance.getNextVCAndRecord(foodArray: foodArray, countArray: countArray, storyBoard: storyboard!) {
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = OrderVCHelper.sharedInstance.getOrderDetailVC(storyboard!)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func handleRequestComplete(data: [Food], categoryId: Int) {
        foodArray = data
        countArray = [Int](count: foodArray.count, repeatedValue: 0)
        tableView.reloadData()
    }
    
    func handleRequestFailed(error: NSError?) {
        // TODO
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
        if item == OrderItem.Sauce {
            return 2    // Food + Option
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return foodArray?.count ?? 0
        if section == 0 {
            return foodArray?.count ?? 0
        } else {
            return kSauceOptions.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("FoodItemCell", forIndexPath: indexPath) as! FoodItemCell
            let thisFood = foodArray[indexPath.row]
            if let url = thisFood.imageUrl {
                cell.foodImageView.imageFromUrl(url)
            }
            cell.nameLabel.text = thisFood.name
            cell.priceLabel.text = "\(thisFood.price) 元"
            cell.countLabel.text = "0"
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("OptionCell", forIndexPath: indexPath)
            cell.textLabel?.text = kSauceOptions[indexPath.row]
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if indexPath.section == 0 {
            // perform the segue
        } else {
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            let option = kSauceOptions[indexPath.row]
            if cell.accessoryType == .None {
                cell.accessoryType = .Checkmark
                OrderVCHelper.sharedInstance.addOption(option)
            } else if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                OrderVCHelper.sharedInstance.removeOption(option)
            }
        }
    }
    
    @IBAction func selectButtonClicked(sender: UIStepper) {
        let point = sender.convertPoint(CGPointZero, toView: tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)!
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FoodItemCell
        cell.countLabel.text = "\(Int(sender.value))"
        
        let index = indexPath.row
        if index >= 0 && index < countArray.count {
            countArray[index] = Int(sender.value)
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let index = self.tableView.indexPathForSelectedRow!.row
        if segue.identifier == "ShowFoodDetail" {
            if let vc = segue.destinationViewController as? FoodDetailViewController {
                vc.food = foodArray[index]
                vc.index = index
            }
            
        }
    }
    
    @IBAction func closeDetailVC(segue: UIStoryboardSegue) {
//        if let vc = segue.sourceViewController as? FoodDetailViewController {
//            selectedFood = vc.food
//            selectedIndex = vc.index
//        }
//        tableView.reloadData()
    }

}
