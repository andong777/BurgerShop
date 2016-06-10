//
//  JsonHelper.swift
//  BurgerShop
//
//  Created by 安东 on 16/5/10.
//  Copyright © 2016年 andong. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import SwiftString

class NetworkHelper {
    
    static let SERVER_URL = "http://101.200.89.174:8080/ocr/hamburger"
    
    // 每类食物的列表
    static let GENERAL_FOOD_LIST_URL = SERVER_URL + "/vegetablesDetails"
    static let BREAD_LIST_URL = SERVER_URL + "/vegetablesDetails?food_id=1"
    static let PATTY_LIST_URL = SERVER_URL + "/vegetablesDetails?food_id=2"
    static let VEGETABLES_LIST_URL = SERVER_URL + "/vegetablesDetails?food_id=3"
    static let CHEESE_LIST_URL = SERVER_URL + "/vegetablesDetails?food_id=4"
    static let SAUCE_LIST_URL = SERVER_URL + "/vegetablesDetails?food_id=5"
    static let OTHER_LIST_URL = SERVER_URL + "/vegetablesDetails?food_id=6"
    
    // 每种状态的订单列表
    // 等待和取消两种情况，不记录
    static let ORDER_LIST_ORDERED_URL = SERVER_URL + "/getOrdersByState?state_id=0"
    static let ORDER_LIST_CONFIRMED_URL = SERVER_URL + "/getOrdersByState?state_id=1"
    static let ORDER_LIST_FINISHED_URL = SERVER_URL + "/getOrdersByState?state_id=2"
    static let ORDER_LIST_URL = SERVER_URL + "/allOrders"
    
    // 订单详情
    static let ORDER_DETAIL_URL = SERVER_URL + "/orderDetails"  // ?order_id=x
    
    // 提交订单
    // 参数：food_detail_ids: 1,2,3 食物详情的id逗号分隔；price: 15总价格
    static let SUBMIT_ORDER_URL = SERVER_URL + "/commitOrder"
    
    // 更新订单状态
    // 参数：order_id: 1；state_id: 1
    static let UPDATE_ORDER_URL = SERVER_URL + "/setOrderState"

    // 主厨推荐列表
    static let RECOMMEND_LIST_URL = SERVER_URL + "/getRecommandFood"
    
    // 主厨推荐详情
    // 参数：recommand_id: 1
    static let RECOMMEND_DETAIL_URL = SERVER_URL + "/getRecommandDetail"
    
    // 修改营养成分
    // 参数：food_detail_id：1
    //      content：{'na': 2, 'sugur': 100}
    static let MODIFY_NUTRITION_URL = SERVER_URL + "/modifyNutrition"
    
    // 提交新食物
    // 参数：file：图片文件
    //      content：{"food_id":1,"name":"tmp","price":5,"energy":200,"protein":10,"fat":20,"na":2, "sugur":100}
    static let ADD_NEW_FOOD_URL = SERVER_URL + "/addDetailFood"
    
    
    /*
         {
             "food_detail_id" = 1;
             image = "http://101.200.89.174:8080/ocr/pics/1.jpg";
             name = "\U677e\U8f6f\U9762\U5305";
             price = 5;
         }
    */
    class func getFoodList(orderItem: OrderItem, completionHandler: (data: [Food], categoryId: Int) -> Void,
                           errorHandler: (error: NSError?) -> Void) {
        let requestUrl: String
        switch orderItem {
        case .Bread:
            requestUrl = BREAD_LIST_URL
        case .Patty:
            requestUrl = PATTY_LIST_URL
        case .Vegetable:
            requestUrl = VEGETABLES_LIST_URL
        case .Cheese:
            requestUrl = CHEESE_LIST_URL
        case .Sauce:
            requestUrl = SAUCE_LIST_URL
        case .Other:
            requestUrl = OTHER_LIST_URL
        }
        
        var ret = [Food]()
        Alamofire.request(.GET, requestUrl).responseJSON { response in
            if let jsonString = response.result.value {
//                print("JSON: \(jsonString)")
                let json = JSON(jsonString)
                let array = json["datalist"]
                for (_, item): (String, JSON) in array {
                    if let id = item["food_detail_id"].int, let name = item["name"].string, let price = item["price"].double, let imageUrl = item["image"].string {
                        let food = Food(id: id, name: name, price: price, imageUrl: imageUrl)
                        
                        // 增加营养信息
                        let nutritionDict = item["nutrition"]
                        var nutrition = [String: Double]()
                        for (key, valueJson): (String, JSON) in nutritionDict {
                            let nutriNum = valueJson.doubleValue
                            nutrition[key] = nutriNum
                        }
                        food.nutrition = nutrition
                        
                        ret.append(food)
                    }
                }
                let catId = orderItem.rawValue
                completionHandler(data: ret, categoryId: catId)
            } else {
                errorHandler(error: nil)
            }
        }
    }
    
    /*
        {
            "order_id": 0,
            "state": 2,
            "createtime": "2016-05-04 14:43:45",
            "total_price": 5
        }
    */
    class func getOrderList(url requestUrl: String, completionHandler: (data: [Order]) -> Void,
                                errorHandler: (error: NSError?) -> Void) {
        var ret = [Order]()
        Alamofire.request(.GET, requestUrl).responseJSON { response in
            print(response.result)
            
            if let jsonString = response.result.value {
                print("JSON: \(jsonString)")
                let json = JSON(jsonString)
                let array = json["datalist"]
                for (_, item): (String, JSON) in array {
                    if let orderId = item["order_id"].int, let state = item["state"].int, let timeString = item["createtime"].string, let price = item["total_price"].double {
                        let orderState = [OrderState.Ordered, OrderState.Confirmed, OrderState.Finished][state % 3]
                        
                        let df = NSDateFormatter()
                        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let time = df.dateFromString(timeString)
                        
                        let order = Order(id: orderId, state: orderState, time: time, price: price)
                        
                        // 获取备注信息
                        if let info = item["info"].string {
                            order.options = info.componentsSeparatedByString("；")
                        }
                        
                        
                        ret.append(order)
                    }
                }
                completionHandler(data: ret)
                
            } else {
                errorHandler(error: nil)
            }
        }
    }
    
    class func getOrderList(completionHandler: (data: [Order]) -> Void,
                              errorHandler: (error: NSError?) -> Void) {
        let requestUrl = ORDER_LIST_URL
        getOrderList(url: requestUrl, completionHandler: completionHandler, errorHandler: errorHandler)
    }
    
    class func getOrderList(state orderState: OrderState, completionHandler: (data: [Order]) -> Void,
                                  errorHandler: (error: NSError?) -> Void) {
        let requestUrl: String
        switch orderState {
        case .Ordered:
            requestUrl = ORDER_LIST_ORDERED_URL
        case .Confirmed:
            requestUrl = ORDER_LIST_CONFIRMED_URL
        case .Finished:
            requestUrl = ORDER_LIST_FINISHED_URL
        default:
            requestUrl = ""
        }
        getOrderList(url: requestUrl, completionHandler: completionHandler, errorHandler: errorHandler)
     }
    
    class func getOrderList(user userType: UserType, completionHandler: (data: [Order]) -> Void,
                                 errorHandler: (error: NSError?) -> Void) {
        let requestUrl: String
        switch userType {
        case .Cook:
            requestUrl = ORDER_LIST_ORDERED_URL
        case .Waiter:
            requestUrl = ORDER_LIST_CONFIRMED_URL
        case .Administrator:
            requestUrl = ORDER_LIST_FINISHED_URL
        default:
            requestUrl = ""
        }
        getOrderList(url: requestUrl, completionHandler: completionHandler, errorHandler: errorHandler)
    }
    
    /*
         {
         "food_detail_id": 1,
         "price": 5,
         "name": "松软面包",
         "image": "http://101.200.89.174:8080/ocr/pics/1.jpg",
         }
    */
    class func getOrderDetail(order: Order, completionHandler: (item: Order) -> Void, errorHandler: (error: NSError?) -> Void) {
        Alamofire.request(.GET, ORDER_DETAIL_URL,
            parameters: ["order_id": order.id!]).responseJSON { response in
                print(response.result)
                if let jsonString = response.result.value {
                    print("JSON: \(jsonString)")
                    let json = JSON(jsonString)
                    let array = json["datalist"]
                    var foodArray = [Food]()
                    var countArray = [Int]()

                    for (_, item): (String, JSON) in array {
                        if let id = item["food_detail_id"].int, let price = item["price"].double, let name = item["name"].string, let image = item["image"].string {
                            let food = Food(id: id, name: name, price: price, imageUrl: image)
                            
                            // 增加营养信息
                            let nutritionDict = item["nutrition"]
                            var nutrition = [String: Double]()
                            for (key, valueJson): (String, JSON) in nutritionDict {
                                let nutriNum = valueJson.doubleValue
                                nutrition[key] = nutriNum
                            }
                            food.nutrition = nutrition

                            foodArray.append(food)
                            
                            let count = item["count"].int ?? 1
                            countArray.append(count)
                        }
                    }
                    
                    let burger = Hamburger(foodArray: foodArray, countArray: countArray)
                    order.hamburger = burger
                    completionHandler(item: order)
                    
                } else {
                    errorHandler(error: nil)
                }
        }

    }
    
    /*
        ["food_detail_ids": "1,2,3", "price": 15]
    */
    class func submitOrder(order: Order, completionHandler: () -> Void, errorHandler: (error: NSError?) -> Void) {
        
        let foodCountArray = order.hamburger!.foodCountArray
        var foodIds = [Int]()
        for i in 0..<foodCountArray.count {
            foodIds.append(foodCountArray[i].food.id)
            foodIds.append(foodCountArray[i].count ?? 1)
        }
        
        var parameters = [String: AnyObject]()
        parameters["food_detail_ids"] = ",".join(foodIds)
        parameters["price"] = order.price!
        parameters["info"] = "；".join(order.options)
        
        Alamofire.request(.POST, SUBMIT_ORDER_URL, parameters: parameters).response { request, response, data, error in
            print(request)
            print(response)
            if error == nil {
                completionHandler()
            } else {
                errorHandler(error: nil)
            }
        }
    }
    
    /*
        ["order_id": 1, "state_id": 1]
        （0-刚下单， 1-初始确认， 2-服务员完成）
    */
    class func updateOrder(order: Order, toState state: OrderState, completionHandler: () -> Void, errorHandler: (error: NSError?) -> Void) {
        let stateId: Int
        switch state {
        case .Confirmed:
            stateId = 1
        case .Finished:
            stateId = 2
        default:
            stateId = 0
        }
        
        if let orderId = order.id {
            let parameters: [String: AnyObject] = ["order_id": orderId, "state_id": stateId]
            Alamofire.request(.POST, UPDATE_ORDER_URL, parameters: parameters).response { request, response, data, error in
                print(request)
                print(response)
                print(data)
                if error == nil {
                    completionHandler()
                } else {
                    errorHandler(error: nil)
                }
            }
        } else {
            errorHandler(error: nil)
        }
        
    }

    class func getRecommendList(completionHandler completionHandler: (data: [RecommendInfo]) -> Void,
                            errorHandler: (error: NSError?) -> Void) {
        var ret = [RecommendInfo]()
        Alamofire.request(.GET, RECOMMEND_LIST_URL).responseJSON { response in
            print(response.result)
            
            if let jsonString = response.result.value {
                print("JSON: \(jsonString)")
                let json = JSON(jsonString)
                let array = json["datalist"]
                for (_, item): (String, JSON) in array {
                    if let id = item["recommand_id"].int {
                        let image = item["image"].string
                        let name = item["name"].string
                        ret.append((id, image, name))
                    }
                }
                completionHandler(data: ret)
                
            } else {
                errorHandler(error: nil)
            }
        }
    }
    
    class func getRecommendDetail(recommendInfo: RecommendInfo, completionHandler: (data: Order) -> Void, errorHandler: (error: NSError?) -> Void) {
        var parameters = [String: AnyObject]()
        parameters["recommand_id"] = recommendInfo.id
        
        Alamofire.request(.GET, RECOMMEND_DETAIL_URL, parameters: parameters).responseJSON { response in
            print(response.result)
            
            if let jsonString = response.result.value {
                print("JSON: \(jsonString)")
                let json = JSON(jsonString)
                let array = json["datalist"]
                var foodArray = [Food]()
                for (_, item): (String, JSON) in array {
                    if let id = item["food_detail_id"].int, let price = item["price"].double, let name = item["name"].string, let image = item["image"].string {
                        let food = Food(id: id, name: name, price: price, imageUrl: image)
                        
                        // 增加营养信息
                        let nutritionDict = item["nutrition"]
                        var nutrition = [String: Double]()
                        for (key, valueJson): (String, JSON) in nutritionDict {
                            let nutriNum = valueJson.doubleValue
                            nutrition[key] = nutriNum
                        }
                        food.nutrition = nutrition
                        
                        foodArray.append(food)
                    }
                }
                
                let burger = Hamburger(foodArray: foodArray)
                let order = Order(hamburger: burger, price: burger.price)
                completionHandler(data: order)
            } else {
                errorHandler(error: nil)
            }
        }
    }
    
    class func modifyNutrition(food: Food, completionHandler: () -> Void, errorHandler: (error: NSError?) -> Void) {
        var parameters = [String: AnyObject]()
        parameters["food_detail_id"] = food.id
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(food.nutrition!, options: NSJSONWritingOptions())
        let nutritionJson = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        print(nutritionJson)
        parameters["content"] = nutritionJson
        
        Alamofire.request(.POST, MODIFY_NUTRITION_URL, parameters: parameters).response { request, response, data, error in
            print(request)
            print(response)
            if error == nil {
                completionHandler()
            } else {
                errorHandler(error: nil)
            }
        }
    }
    
    class func addNewFood(food: Food, image: UIImage?, completionHandler: () -> Void, errorHandler: (error: NSError?) -> Void) {
        var parameters = [String: AnyObject]()
        var innerParams = [String: AnyObject]()
        innerParams["food_id"] = food.category?.rawValue
        innerParams["name"] = food.name
        innerParams["price"] = food.price
//        innerParams["nutrition"] = food.nutrition!
        if let nutrition = food.nutrition {
            for (k, v) in nutrition {
                innerParams[k] = v
            }
        }
        
//        if let image = image {
//            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//            let filePath = "\(paths[0])/temp.png"
//            UIImagePNGRepresentation(image)?.writeToFile(filePath, atomically: true)
//            parameters["file"] = filePath
//        }
        
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(innerParams, options: NSJSONWritingOptions())
        let innerParamsJson = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        print(innerParamsJson)
        parameters["content"] = innerParamsJson
        
//        Alamofire.request(.POST, ADD_NEW_FOOD_URL, parameters: parameters).response { request, response, data, error in
//            print(request)
//            print(response)
//            if error == nil {
//                completionHandler()
//            } else {
//                errorHandler(error: nil)
//            }
//        }
        
        Alamofire.upload(.POST, ADD_NEW_FOOD_URL, multipartFormData: {
            multipartFormData in
            if let image = image {
                if let imageData = UIImagePNGRepresentation(image) {
                    multipartFormData.appendBodyPart(data: imageData, name: "image", fileName: "image.png", mimeType: "image/png")
                }
            }
            for (key, value) in parameters {
                multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
            }
            }, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                    completionHandler()
                case .Failure(let encodingError):
                    print(encodingError)
                    errorHandler(error: nil)
                }
            }
        )
    }
    
}