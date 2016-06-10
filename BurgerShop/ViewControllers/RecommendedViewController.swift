//
//  RecommendedViewController.swift
//  BurgerShop
//
//  Created by andong on 16/5/15.
//  Copyright © 2016年 andong. All rights reserved.
//

import UIKit

class RecommendedViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var burgerArray: [RecommendInfo]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = false

        NetworkHelper.getRecommendList(completionHandler: handleRequestComplete, errorHandler: handleRequestFailed)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRequestComplete(data: [(id: Int, image: String?, name: String?)]) {
        burgerArray = data
        collectionView?.reloadData()
    }
    
    func handleRequestFailed(error: NSError?) {
        // TODO
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + (burgerArray?.count ?? 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let windowSize = view.window!.bounds.size
        let width = windowSize.width * 0.45;
        return CGSize(width: width, height: width)
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        let cell: UICollectionViewCell
        if index == 0 {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("NewBurgerItemCell", forIndexPath: indexPath)
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("BurgerItemCell", forIndexPath: indexPath)
            let burger = burgerArray[index - 1]
            if let imageView = cell.viewWithTag(1) as? UIImageView, imageUrl = burger.image {
                imageView.imageFromUrl(imageUrl)
            }
            if let nameLabel = cell.viewWithTag(2) as? UILabel {
                nameLabel.text = burger.name
            }
        }
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowNewBurger" {
            OrderVCHelper.sharedInstance.prepareForFirstVC()
        } else if segue.identifier == "ShowBurger" {
            if let vc = segue.destinationViewController as? OrderDetailViewController {
                let index = self.collectionView!.indexPathsForSelectedItems()![0].row - 1
                vc.recommendInfo = burgerArray[index]
            }
        }
    }

}
