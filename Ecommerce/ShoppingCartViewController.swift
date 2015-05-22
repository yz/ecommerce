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
    
    var dictIndexToHierarchy = [Int: String]()
    
    convenience init(className: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        layout.minimumInteritemSpacing = 5.0
        self.init(collectionViewLayout: layout,className : className)
        pullToRefreshEnabled = true
        paginationEnabled = false
        
        super.collectionView?.allowsMultipleSelection = true
        super.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Checkout", style: UIBarButtonItemStyle.Plain, target: self, action: "checkOut")
    }
    
    func getNumOfItems()->(Int64){
        var count:Int64 = 0
        if let productsInCart = queryForCollection().findObjects(){
            for product in productsInCart{
                var numItems = getCount(product["Hierarchy"] as String)
                count += numItems
            }
        }
        return count
    }
    
    //Call from PaymentViewController only !!
    func clearShoppingCart()->(){
        if PFUser.currentUser()==nil
        {
            //Not possible.
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
                var cart:PFObject = cartList.getFirstObject() as PFObject
                cart.delete()
                SecondViewController.init_cart(PFUser.currentUser())
            }else{
                //Do nothing
            }
        }
    }
    
    func checkOut()
    {
         println("Code for checkout with items in the shopping cart")
        let paymentView : PaymentViewController = PaymentViewController(nibName:"PaymentViewController",bundle:nil)
        paymentView.price = 0
        paymentView.parent = self
        
        for product in queryForCollection().findObjects(){
            var numItems = Float64(getCount(product["Hierarchy"] as String))
            paymentView.price += numItems * (product["unitPrice"] as Float64)
        }
        
        var alert = UIAlertController(title: "Total Cost", message: "The total cost is $\(paymentView.price.description). Do you want to proceed?", preferredStyle: UIAlertControllerStyle.Alert)
        
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
            //return PFQuery() // WAS BE A PROBLEM. IS NOW THE SOLUTION
            var qry = PFQuery()//super.queryForCollection() WHY DID THIS STOP WORKING NOW?
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
            println(currCart.query().countObjects())
            return currCart.query()
        }
    }
    
    func removeItemFromCart(usr:String, path:String)->(Bool){
        var removed:Bool = false
        var hrchy = path
        path.replace(".*\\.", template: "")
        var row:PFObject! = nil
        var productList:PFQuery = PFQuery(className: "Product");
        var custList:PFQuery = PFQuery(className: "_User");
        var cartList:PFQuery = PFQuery(className: "Cart");
        
        
        var matchPattern = "\(hrchy)"
        productList = productList.whereKey("Hierarchy", matchesRegex: matchPattern)
        custList = custList.whereKey("email", equalTo: usr)
        
        if(productList.countObjects() != 0 && custList.countObjects() == 1){//Objects exists
            
            var customer:PFObject = custList.getFirstObject() as PFObject
            cartList = cartList.whereKey("customer", equalTo: customer)
            if let iscartthere = cartList.getFirstObject(){
                //Do nothing.
            }else{
                //Initialize cart if missing
                SecondViewController.init_cart(PFUser.currentUser())
                return false
            }
            var cart:PFObject = cartList.getFirstObject() as PFObject
            var currCart:PFRelation = cart.relationForKey("Product")
            
            for obj in productList.findObjects(){
                row = obj as PFObject
                if row["productType"] as Int == 1{//Valid item selected, add to cart
                    
                    let cnt:String = cart["count"] as String
                    var res:String = ""
                    for keyval in cnt.componentsSeparatedByString("%"){
                        if !keyval.isEmpty{
                            let kv:[String] = keyval.componentsSeparatedByString("=")
                            var k = kv[0]
                            var v = kv[1]
                            if k == row["Hierarchy"] as String{
                                
                                if v.toInt() > 0{
                                    v = String(v.toInt()! - 1)
                                    row["count"] = row["count"] as Int + 1
                                }
                                
                                if v.toInt() <= 0{
                                    currCart.removeObject(row) //No longer in cart. Remove relation
                                    continue//Count of this item is no longer added
                                }
                                
                                removed = true
                            }
                            
                            if res.isEmpty{
                                res = k + "=" + v
                            }else{
                                res = res + "%" + k + "=" + v
                            }
                        }
                    }
                    
                    cart["count"] = res
                    row.save()
                    cart.save()
                    println("Saved objects")
                }
            }
        }
        
        return removed
    }
    
    func getCount(var hierarchy:String)->(Int){
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
        
        let cnt:String = cart["count"] as String
        for keyval in cnt.componentsSeparatedByString("%"){
            if !keyval.isEmpty{
                let kv:[String] = keyval.componentsSeparatedByString("=")
                var k = kv[0]
                var v = kv[1]
                if k == hierarchy{
                    return v.toInt()!
                }
            }
        }
        return 0
    }
    
    // MARK: CollectionView
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath, object: object)
        
        cell?.textLabel.textAlignment = .Center
        println(object?)
        
        
        //   Eg. To display items from the product table
        var productTitle = object?["Hierarchy"] as String
        var imageLink = object?["itemImage"] as String
        
        dictIndexToHierarchy[indexPath.item] = productTitle
        
        //println(imageLink)
        cell?.textLabel.text = productTitle.replace(".*\\.", template: "") + "( " + String(getCount(String(object?["Hierarchy"] as NSString))) + " )"
        cell?.contentView.layer.borderWidth = 1.0
        cell?.contentView.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell?.imageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: imageLink)!)!)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            println(indexPath.item)
        
    
        return true
        
    }
    
    override func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        var cell = collectionView.cellForItemAtIndexPath(indexPath) as UICollectionViewCell?
        cell?.contentView.backgroundColor = UIColor.blueColor()
    }
    
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }

    func setShoppingCartBadge()
    {
        var tabBarItem = self.tabBarController?.tabBar.items?.last as UITabBarItem
        var count = getNumOfItems()
        if count>0
        {
            tabBarItem.badgeValue = "\(count)"
        }
        else
        {
            tabBarItem.badgeValue = nil
        }
    }
    
    func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        if gestureRecognizer.state != UIGestureRecognizerState.Ended{
            return
        }
        
        let p = gestureRecognizer.locationInView(self.collectionView)
        
        let indexPath = self.collectionView?.indexPathForItemAtPoint(p)
        
        if let index = indexPath {
            var cell = self.collectionView?.cellForItemAtIndexPath(index)
            // do stuff with your cell, for example print the indexPath
            
            let currentUser = PFUser.currentUser()
            currentUser.fetch()
            removeItemFromCart(currentUser["email"] as String, path: dictIndexToHierarchy[index.item]!)
            println("Long pressed \(dictIndexToHierarchy[index.item])")
            navigationItem.title = "My Cart (\(getNumOfItems()))"
            setShoppingCartBadge()
            self.loadObjects()
            self.collectionView?.reloadData()
            
        } else {
            println("Could not find index path")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView?.addGestureRecognizer(lpgr)
        self.collectionView?.reloadData()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        // navigationItem.title = &quot;One&quot;
        setShoppingCartBadge()
        self.loadObjects()
        self.collectionView?.reloadData()
        navigationItem.title = "My Cart (\(getNumOfItems()))"
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
        layout.minimumInteritemSpacing = 5.0
        pullToRefreshEnabled = true
        paginationEnabled = false
        super.collectionView?.allowsMultipleSelection = true
        super.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Checkout", style: UIBarButtonItemStyle.Plain, target: self, action: "checkOut")
        
        super.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Remove Item", style: UIBarButtonItemStyle.Plain, target: self, action: "removeFromCartAlert")
    }
    
    func removeFromCartAlert()
    {
        var alert = UIAlertController(title: "To remove an item from the cart", message: "Long press on the corresponding item", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
            println("Ok")
        
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }


}
