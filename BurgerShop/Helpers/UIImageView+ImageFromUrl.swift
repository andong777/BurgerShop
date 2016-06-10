//
//  UIImageView+ImageFromUrl.swift
//  BurgerShop
//
//  Created by 安东 on 16/5/11.
//  Copyright © 2016年 andong. All rights reserved.
//

import Foundation
import UIKit

public extension UIImageView {
    public func imageFromUrl(urlString: String) {
        let request = NSURLRequest(URL: NSURL(string: urlString)!)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error != nil {
                print("Failed to load image for url: \(urlString), error: \(error?.description)")
                return
            }
            guard let httpResponse = response as? NSHTTPURLResponse else {
                print("Not an NSHTTPURLResponse from loading url: \(urlString)")
                return
            }
            if httpResponse.statusCode != 200 {
                print("Bad response statusCode: \(httpResponse.statusCode) while loading url: \(urlString)")
                return
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.image = UIImage(data: data!)
            })
            }.resume()
    }
}