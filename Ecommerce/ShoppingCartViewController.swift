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

class ShoppingCartViewController: PFQueryCollectionViewController,UIGestureRecognizerDelegate{
    
    var cartCount:Int = 0
    func checkOut()
    {
         println("Code for checkout with items in the shopping cart")
        let paymentView : PaymentViewController = PaymentViewController(nibName:"PaymentViewController",bundle:nil)
        paymentView.price = 0
        for product in queryForCollection().findObjects(){
            var numItems = Float64(getCount(product["Hierarchy"] as String))
            paymentView.price += numItems * (product["unitPrice"] as Float64)
        }
        
        var alert = UIAlertController(title: "Total Cost", message: paymentView.price.description, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
            println("Ok")
            
        self.navigationController?.pushViewController(paymentView, animated: true)
            
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { action in
            println("Cancel")
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    // MARK: UIViewController
    
    override func viewWillAppear(animated: Bool) {
        // navigationItem.title = &quot;One&quot;
        navigationItem.title = "Items in the Cart : \(cartCount)"
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        layout.minimumInteritemSpacing = 5.0
        pullToRefreshEnabled = true
        paginationEnabled = false
        super.collectionView?.allowsMultipleSelection = true
        super.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Checkout", style: UIBarButtonItemStyle.Plain, target: self, action: "checkOut")
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView?.addGestureRecognizer(lpgr)
    
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            let bounds = UIEdgeInsetsInsetRect(view.bounds, layout.sectionInset)
            let sideLength = min(CGRectGetWidth(bounds), CGRectGetHeight(bounds)) / 2.0 - layout.minimumInteritemSpacing
            layout.itemSize = CGSizeMake(sideLength, sideLength)
        }
        
        //removeItemFromCart("b@c.com", path:"All.Clothing.Shirts.Canadian Lumber Jack") //TEST CODE! REMOVE IT!
    }
    
    // MARK: Data
    
    override func queryForCollection() -> PFQuery {
        
        if PFUser.currentUser()==nil
        {
            //return PFQuery() // IS BE A PROBLEM
            var qry = super.queryForCollection()
            return qry.whereKey("NON_EXISTANT_KEY", equalTo: "NON_EXISTANT_VALUE") //RETURN A QUERY THAT IS GAURANTEED TO RETURN NOTHING. BAD CODE !
        }
        else{
            var custList:PFQuery = PFQuery(className: "_User");
            var cartList:PFQuery = PFQuery(className: "Cart");
            var forCustomer:PFUser = PFUser.currentUser()
            forCustomer.fetch()
            custList = custList.whereKey("email", equalTo: forCustomer["email"] as String)
            var customer:PFObject = custList.getFirstObject() as PFObject
            cartList = cartList.whereKey("customer", equalTo: customer)
            if let iscartthere = cartList.getFirstObject(){
                //Do nothing.
            }else{
                //Initialize cart if missing
                SecondViewController.init_cart(PFUser.currentUser())
            }
            var cart:PFObject = cartList.getFirstObject() as PFObject
            var currCart:PFRelation = cart.relationForKey("Product")
            println("No of objects in the cart are \(currCart.query().countObjects())");
            cartCount = currCart.query().countObjects()
            return currCart.query()
        }
    }
    
    
    
    // MARK: CollectionView
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath, object: object)
        
        cell?.textLabel.textAlignment = .Center
        println(object?)
        
        
        //   Eg. To display items from the product table
        
        var productTitle = object?["Hierarchy"] as String
        productTitle = productTitle.replace(".*\\.", template: "")
        
        var imageLink = object?["itemImage"] as String
        
        println(imageLink)
        cell?.textLabel.text = productTitle + "( " + String(getCount(String(object?["Hierarchy"] as NSString))) + " )"
        cell?.contentView.layer.borderWidth = 1.0
        cell?.contentView.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell?.imageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: imageLink)!)!)
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            println(indexPath.item)
        
    
        return true
        
    }
    
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    
    // Long press
    func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        if gestureRecognizer.state != UIGestureRecognizerState.Ended{
            return
        }
        
        let p = gestureRecognizer.locationInView(self.collectionView)
        
        let indexPath = self.collectionView?.indexPathForItemAtPoint(p)
        
        if let index = indexPath {
            var cell = self.collectionView?.cellForItemAtIndexPath(index)
            // do stuff with your cell, for example print the indexPath
            println("Long pressed \(index.row)")
        } else {
            println("Could not find index path")
        }
    }

}
