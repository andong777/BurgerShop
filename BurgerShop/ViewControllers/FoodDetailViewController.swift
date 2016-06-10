//
//  FoodDetailViewController.swift
//  BurgerShop
//
//  Created by 安东 on 16/5/5.
//  Copyright © 2016年 andong. All rights reserved.
//

import UIKit

class FoodDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var food: Food! {
        didSet {
            if let nutrition = food.nutrition {
                nutritionKeys = Array(nutrition.keys)
            } else {
                nutritionKeys = [String]()
            }
        }
    }
    var index: Int!
    
    var nutritionKeys: [String]!
    
    // outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    init(food: Food) {
        self.food = food
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = food.name
        if let imageUrl = food.imageUrl {
            imageView.imageFromUrl(imageUrl)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2    // 食物信息 + 营养信息
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1    // 目前只有价格
        } else {
            return food.nutrition?.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FoodPropertyCell", forIndexPath: indexPath)
        let index = indexPath.row
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "价格："
            cell.detailTextLabel?.text = "\(food.price) 元"
        } else {
            let key = nutritionKeys[index]
            cell.textLabel?.text = "\(key)"
            if let nutritionItem = food.nutrition?[key] {
                cell.detailTextLabel?.text = "\(nutritionItem)"
            }
        }
        
        return cell
    }
    
}
