//
//  ShoppingCartViewController.swift
//  Ecommerce
//
//  Created by Ashwinkarthik Srinivasan on 4/23/15.
//  Copyright (c) 2015 Ashwinkarthik Srinivasan. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ShoppingCartViewController: PFQueryCollectionViewController {

    
    
    
    
    convenience init(className: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        layout.minimumInteritemSpacing = 5.0
        self.init(collectionViewLayout: layout, className: className)
        
        title = "Shopping Cart"
        pullToRefreshEnabled = true
        paginationEnabled = false
    }
    
    // MARK: UIViewController
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            let bounds = UIEdgeInsetsInsetRect(view.bounds, layout.sectionInset)
            let sideLength = min(CGRectGetWidth(bounds), CGRectGetHeight(bounds)) / 2.0 - layout.minimumInteritemSpacing
            layout.itemSize = CGSizeMake(sideLength, sideLength)
        }
    }
    
    // MARK: Data
    
    override func queryForCollection() -> PFQuery {

        
        return super.queryForCollection()
        
    }
    
    // MARK: CollectionView
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath, object: object)
        
        cell?.textLabel.textAlignment = .Center
        println(object?)
        
        /*
        var customer : PFRelation = object?["Customer"] as PFRelation
        var product : PFRelation = object?["Product"] as PFRelation
        
        var customerQuery = customer.query()
        var productQuery = product.query()
        
        var prodObj = productQuery.getFirstObject()
        
        println(product)
        
        */
        
        
        //   Eg. To display items from the product table
        /*
        var productTitle = object?["Hierarchy"] as String
        productTitle = productTitle.replace(".*\\.", template: "")
        
        var imageLink = object?["itemImage"] as String
        
        println(imageLink)
        cell?.textLabel.text = productTitle
        cell?.contentView.layer.borderWidth = 1.0
        cell?.contentView.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell?.imageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: imageLink)!)!)
        */
        
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            println(indexPath.item)
        return true
        
    }
    
    
}
