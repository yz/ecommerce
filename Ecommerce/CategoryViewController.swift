//
//  CategoryViewController.swift
//  Mobile Store
//
//  Created by Ashwinkarthik Srinivasan on 3/6/15.
//  Copyright (c) 2015 Yun Zhang. All rights reserved.
//

import UIKit
import Parse

struct Stack<T> {
    var items = [T]()
    mutating func push(item: T) {
        items.append(item)
    }
    mutating func pop() -> T {
        return items.removeLast()
    }
}

// CONSTANTS
let reuseIdentifier = "CategoryCell"
let folderImgURL = "http://icons.iconarchive.com/icons/kyo-tux/aeon/256/Folder-Blue-Folder-icon.png"

var categoryList = []

var productList = []

var categorySelected : Int = -1

var currentRoot:String = "All"
var hierarchyStack = Stack<String>()

class CategoryViewController: UICollectionViewController {
   
    //REMOVE CODE ! -- ONLY FOR TESTING PURPOSE!
    func init_cart()->(){
        var custList:PFQuery = PFQuery(className: "_User");
        custList = custList.whereKey("customerId", equalTo: 123456789)
        var customer:PFObject = custList.getFirstObject() as PFObject
        var cartList:PFQuery = PFQuery(className: "Cart");
        var cart:PFObject = cartList.findObjects()[0] as PFObject
        //cart["_User"] = customer
        var pfrCartCustomer:PFRelation = cart.relationForKey("_User")
        pfrCartCustomer.addObject(customer)
        cart.saveEventually(nil)
        //cart.saveInBackgroundWithBlock(nil)
    }
    
    func addItemToCart(usr:Int, path:String)->(){
        var hrchy = path
        path.replace(".*\\.", template: "")
        var row:PFObject! = nil
        var productList:PFQuery = PFQuery(className: "Product");
        var custList:PFQuery = PFQuery(className: "_User");
        var cartList:PFQuery = PFQuery(className: "Cart");
        
        
        var matchPattern = "\(hrchy)"
        productList = productList.whereKey("Hierarchy", matchesRegex: matchPattern)
        custList = custList.whereKey("customerId", equalTo: usr)
        
        if(productList.countObjects() != 0 && custList.countObjects() == 1){//Objects exists
            
            var customer:PFObject = custList.getFirstObject() as PFObject
            cartList = cartList.whereKey("_User", equalTo: customer)
            var cart:PFObject = cartList.getFirstObject() as PFObject
            11
            var currCart:PFRelation = cart.relationForKey("Product")
            
            for obj in productList.findObjects(){
                row = obj as PFObject
                if row["productType"] as Int == 1{//Valid item selected, add to cart
                    currCart.addObject(row)
                }
            }
            
            cart.saveEventually(nil)
            //cart.saveInBackgroundWithBlock(nil)
        }
    }

    func dropItem(path:String)->(){
        var hrchy = path
        path.replace(".*\\.", template: "")
        var row:PFObject! = nil
        var productList:PFQuery = PFQuery(className: "Product");
        var matchPattern = "\(hrchy)"
        productList = productList.whereKey("Hierarchy", matchesRegex: matchPattern)
        if(productList.countObjects() != 0){//Object exists
            for obj in productList.findObjects(){
                row = obj as PFObject
                if row["productType"] as Int == 1{
                    row.deleteInBackgroundWithBlock(nil)}
            }
        }

    }
    
    func addOrModifyItem(path:[String], properties:[String:AnyObject])->(){
        
        if(path.count == 0){
            return
        }
        
        var hrchy = path[0]
        for i in Range(start:1, end:path.count){
            
            if(retrieveListing(hrchy).count == 0){
                var row:PFObject = PFObject(className:"Product")
                row["productType"] = 0
                row["Hierarchy"] = hrchy
                row["itemImage"] = folderImgURL
                row.saveInBackgroundWithBlock(nil)
            }
            
            hrchy += "." + path[i]
        }
        
        var row:PFObject! = nil
        var productList:PFQuery = PFQuery(className: "Product");
        var matchPattern = "\(hrchy)"
        productList = productList.whereKey("Hierarchy", matchesRegex: matchPattern)
        
        if(productList.countObjects() == 0){//Create new object
            row = PFObject(className:"Product")
            row["productType"] = 1
            row["Hierarchy"] = hrchy
        }else{//Modify existing object
            for obj in productList.findObjects(){
                row = obj as PFObject
            }
        }
        
        for p in properties{
            row[p.0] = p.1
        }
        row.saveInBackgroundWithBlock(nil)
    }
    
    func getSubCategoriesObjectIDs( productList: PFQuery , categoryName: String) -> [[String]]{
        var ret: [[String]] = []
        
        for obj in productList.findObjects(){
            var inLst:[String] = []
            inLst.append(obj["Hierarchy"] as String)
            inLst.append(obj["itemImage"] as String)
            ret.append(inLst)
        }
        return ret
    }
        // Gets the next set of categories for the given input category
    func retrieveListing(categoryName :String) ->[[String]]{

        println("Retrieving list for \(categoryName)")
        var productList:PFQuery = PFQuery(className: "Product");
        
        
        //var matchPattern = ".*\(categoryName).*"
        var matchPattern = "\(categoryName)\\.[^\\.]*$"
   
        productList = productList.whereKey("Hierarchy", matchesRegex: matchPattern)  // retrieves the set of products that matched the input
        
         return getSubCategoriesObjectIDs(productList, categoryName : categoryName)
        //return getSubCategories(productList, categoryName : categoryName) // From the retrieved set of products gets the sub category list
    }
    
    
    // GESTURE CONTROL
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left && currentRoot != "All") {
            currentRoot = hierarchyStack.pop()
            navigationItem.title=currentRoot.stringByReplacingOccurrencesOfString(".", withString:" > ", options: NSStringCompareOptions.LiteralSearch, range: nil)
            categoryList = retrieveListing("\(currentRoot)")
            self.collectionView?.reloadData()
        }else if (sender.direction == .Down && currentRoot != "All") {
            navigationItem.title=currentRoot.stringByReplacingOccurrencesOfString(".", withString:" > ", options: NSStringCompareOptions.LiteralSearch, range: nil)
            categoryList = retrieveListing("\(currentRoot)")
            self.collectionView?.reloadData()
            
            dropItem(currentRoot)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Add gesture control
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        leftSwipe.direction = .Left
        var downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        downSwipe.direction = .Down
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(downSwipe)
        
        //Set title
        navigationItem.title=currentRoot
        
        
        Parse.setApplicationId("T5COsNbanlLkzcafpo6CkyeXlRNNvkL5RqQv8isL", clientKey: "n1Ko6El8LjehGEzZFSjDYFoCNSVt8tCMsJG0ftp5")
        println("Category Count:\(categoryList.count)")
        categoryList=retrieveListing(currentRoot)
        println("Category Count:\(categoryList.count)")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
    //    self.collectionView!.registerClass(CategoryViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        //addOrModifyItem(["All", "Toys", "Panda"], properties: ["itemImage":"http://images4.fanpop.com/image/photos/16200000/Pandas-pandas-16256344-600-750.jpg"])
        init_cart()
        addItemToCart(123456789, path: "All.Electronics.Phones.Samsung Galaxy")    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return categoryList.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as CategoryViewCell
    
        var itemStr:String = (categoryList[indexPath.item][0]) as String
        itemStr = itemStr.replace(".*\\.", template: "")
        
        cell.categoryNameLabel.text = "\(itemStr)"
        cell.categoryImage.image=UIImage(data: NSData(contentsOfURL: NSURL(string: (categoryList[indexPath.item][1]) as String)!)!)
      
      
        //cell.categoryNameLabel.text = "\(subCategoryList[categorySelected][indexPath.item])"
        //cell.backgroundColor = UIColor.redColor()

      return cell
    }

    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(180,180)
    }
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }*/
    

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        /*
        hierarchyStack.push(currentRoot)
        currentRoot = (categoryList[indexPath.item][0]) as String
        navigationItem.title=currentRoot.stringByReplacingOccurrencesOfString(".", withString:" > ", options: NSStringCompareOptions.LiteralSearch, range: nil)
        categoryList = retrieveListing("\(currentRoot)")
        self.collectionView?.reloadData()
        */
        
        let nextLevel : CategoryCollectionView = CategoryCollectionView(nibName:"CategoryCollectionView",bundle:nil) as CategoryCollectionView
        
        nextLevel.title = "Collection View Next Level"
        
        self.navigationController?.pushViewController(nextLevel, animated: true)
        
        
        return true
    }


    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
