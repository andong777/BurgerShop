//
//  FoodNutritionViewController.swift
//  BurgerShop
//
//  Created by andong on 16/5/25.
//  Copyright © 2016年 andong. All rights reserved.
//

import UIKit

class FoodNutritionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let foodProperties = ["名字", "价格", "类别"]
    var nutritionArray = [(key: String, value: Double)]()
    
    var food: Food!
    var newFood = true  // new food or existing food

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var nameInput: UITextField!
    var priceInput: UITextField!
    var categoryInput: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.hidden = true
        pickerView.showsSelectionIndicator = true
        
        let singleTap = UITapGestureRecognizer(target: self, action:#selector(tapImage(_:)))
        singleTap.numberOfTapsRequired = 1
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)

        newFood = (food == nil)
        if newFood {
            food = Food()
        }
        
        if let nutrition = food.nutrition {
            for (k, v) in nutrition {
                nutritionArray.append((key: k, value: v))
            }
        }
        
        if newFood {
            imageView.image = UIImage(imageLiteral: "PlusButton")
        } else {
            if let imageUrl = food.imageUrl {
                imageView.imageFromUrl(imageUrl)
            } else {
                imageView.image = UIImage(imageLiteral: "BrokenImage")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tapImage(sender: UIImageView) {
        let vc = UIImagePickerController()
        vc.sourceType = .PhotoLibrary
        vc.allowsEditing = false
        vc.delegate = self
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func handleUploadRequestComplete() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func handleUploadRequestFailed(error: NSError?) {
        let alert = UIAlertController(title: "提交失败！", message: "请检查并重试", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showPicker(sender: AnyObject) {
        pickerView.hidden = false
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return foodProperties.count
        } else {
            return nutritionArray.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        
        if indexPath.section == 0 {
            // name、price、category
            if index == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("FoodPropertyCellCategory", forIndexPath: indexPath)
                let button = cell.viewWithTag(1) as! UIButton
                button.setTitle(food.category?.description, forState: .Normal)
                button.addTarget(self, action: #selector(showPicker(_:)), forControlEvents: .TouchUpInside)
                button.enabled = newFood
                categoryInput = button
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("FoodPropertyCell", forIndexPath: indexPath) as! FoodPropertyCell
                cell.label.text = foodProperties[index]
                if index == 0 {
                    cell.input.text = food.name
                    cell.input.keyboardType = .Default
                    nameInput = cell.input
                } else if index == 1 {
                    cell.input.text = "\(food.price)"
                    cell.input.keyboardType = .DecimalPad
                    priceInput = cell.input
                }
                cell.input.delegate = self
                cell.input.enabled = newFood
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("FoodNutritionCell", forIndexPath: indexPath) as! FoodNutritionCell
            let key = nutritionArray[index].key
            cell.input1.text = key
            cell.input2.text = "\(nutritionArray[index].value)"
            cell.input2.keyboardType = .DecimalPad
            cell.input1.tag = 100 + index
            cell.input2.tag = 200 + index
            cell.input1.delegate = self
            cell.input2.delegate = self
            return cell
        }
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            let index = indexPath.row
            tableView.beginUpdates()
            nutritionArray.removeAtIndex(index)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
            tableView.endUpdates()
        }
    }
    
    @IBAction func addNutrition(sender: AnyObject) {
        tableView.beginUpdates()
        let newNutritionItem: (String, Double) = (key: "", value: 0.0)
        nutritionArray.append(newNutritionItem)
        let indexPath = NSIndexPath(forRow: nutritionArray.count - 1, inSection: 1)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        tableView.endUpdates()
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
    
    @IBAction func submitChanges(sender: AnyObject) {
        food.name = nameInput.text ?? ""
        food.price = Double(priceInput.text ?? "") ?? 0
        
        var nutrition = [String: Double]()
        for i in 0..<nutritionArray.count {
            let nutri = nutritionArray[i]
            nutrition[nutri.key] = nutri.value
        }
        food.nutrition = nutrition
        
        if newFood {
            NetworkHelper.addNewFood(food, image: imageView.image, completionHandler: handleUploadRequestComplete, errorHandler: handleUploadRequestFailed)
        } else {
            NetworkHelper.modifyNutrition(food, completionHandler: handleUploadRequestComplete, errorHandler: handleUploadRequestFailed)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage   // todo
        imageView.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return OrderItem.allValues.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return OrderItem.allValues[row].description
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        food.category = OrderItem.allValues[row]
        categoryInput.titleLabel?.text = food.category?.description
        pickerView.hidden = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let tag = textField.tag
        let zone = tag / 100
        let index = tag % 100
        if zone == 1 {
            nutritionArray[index].key = textField.text!
        } else if zone == 2 {
            nutritionArray[index].value = Double(textField.text!) ?? 0
        } else {
            // 是其他的文本框
        }
    }

}
