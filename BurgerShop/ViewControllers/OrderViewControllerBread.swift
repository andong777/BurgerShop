//
//  OrderViewControllerBread.swift
//  BurgerShop
//
//  Created by andong on 16/5/22.
//  Copyright © 2016年 andong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class OrderViewControllerBread: AbstractOrderViewController {
    
    var foodArray: [Food]!
    var selectedFood: Food?
    var selectedIndex: Int?
    
    private var backButton: UIBarButtonItem!
    private var nextButton: UIBarButtonItem!
    
    private var _hasSelectedItem = false
    private var hasSelectedItem: Bool {
        get {
            return _hasSelectedItem
        }
        set {
            _hasSelectedItem = newValue
            nextButton.enabled = _hasSelectedItem
        }
    }
    
    private var lastSelectedButton: UIButton?
    
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
        
        //        tableView.registerClass(FoodItemCell.self, forCellReuseIdentifier: "FoodItemCellIdentifier")
        
        // 调用Web API，获取显示数据
        let req = Alamofire.request(.GET, "https://httpbin.org/get")
        print(req)
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
        if let selectedFood = selectedFood {
            if let vc = OrderVCHelper.sharedInstance.getNextVCAndRecord(food: selectedFood, storyBoard: storyboard!) {
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = OrderVCHelper.sharedInstance.getOrderDetailVC(storyboard!)
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            // 提示必须选择一个面包！
            let alert = UIAlertController(title: "“面包”不能为空", message: "请选择一种面包", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func handleRequestComplete(data: [Food], categoryId: Int) {
        foodArray = data
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
        return foodArray?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FoodItemCell", forIndexPath: indexPath)
        let idx = indexPath.row
        let thisFood = foodArray[idx]
        if let imageView = cell.viewWithTag(1) as? UIImageView, let url = thisFood.imageUrl {
            imageView.imageFromUrl(url)
        }
        if let nameLabel = cell.viewWithTag(2) as? UILabel {
            nameLabel.text = thisFood.name
        }
        if let priceLabel = cell.viewWithTag(3) as? UILabel {
            priceLabel.text = "\(thisFood.price) 元"
        }
        if let selIdx = selectedIndex {
            if idx == selIdx {
                cell.accessoryType = .Checkmark
            } else {
                
            }
        }
        //        cell.nameLabel.text = thisFood.name
        //        cell.priceLabel.text = "\(thisFood.price) 元"
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    @IBAction func selectButtonClicked(sender: UIButton) {
        let point = sender.convertPoint(CGPointZero, toView: tableView)
        let index = tableView.indexPathForRowAtPoint(point)!.row
        
        if selectedIndex == nil || index != selectedIndex {
            selectedIndex = index
            lastSelectedButton?.setImage(UIImage(imageLiteral: "PlusButton"), forState: .Normal)
            sender.setImage(UIImage(imageLiteral: "MinusButton"), forState: .Normal)
            selectedFood = foodArray[index]
            lastSelectedButton = sender
        } else {
            selectedIndex = nil
            sender.setImage(UIImage(imageLiteral: "PlusButton"), forState: .Normal)
            selectedFood = nil
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
    
}
