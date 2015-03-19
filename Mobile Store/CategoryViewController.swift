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

let reuseIdentifier = "CategoryCell"


var categoryList = []

var productList = []

var categorySelected : Int = -1

var currentRoot:String = "All"
var hierarchyStack = Stack<String>()
//var my1Image = UIImage(named: "Apple_Swift_Logo")
var myImage = UIImage(data: NSData(contentsOfURL: NSURL(string: "https://www.gravatar.com/avatar/a3495409c37d14319939f6c0527db7ce?s=128&d=identicon&r=PG&f=1")!)!)

class CategoryViewController: UICollectionViewController {
    
    func getSubCategoriesObjectIDs( productList: PFQuery , categoryName: String) -> [[String]]{
        var ret: [[String]] = []
        
        for obj in productList.findObjects(){
            var inLst:[String] = []
            inLst.append(obj["Hierarchy"] as! String)
            inLst.append(obj["itemImage"] as! String)
            ret.append(inLst)
        }
        return ret
    }
    /*
    func getSubCategories( productList: PFQuery , categoryName: String) -> [String]{
        var list = [String : Bool ] ()
        var nextSetOfCategories = [String] ()
        
        for obj in productList.findObjects(){
            var heirarchy =  obj["Hierarchy"] as String
            
            let needle: Character = "."
            var end=false
            var found=false
            
            while(!end)
            {
                if let idx = find(heirarchy,needle) {
                    var searchCategory = heirarchy.substringToIndex(idx)
                    //println("Search Category:\(searchCategory)")
                    if(categoryName==searchCategory)
                    {
                        println("Reached the current level")
                        found=true
                    }
                    else if(found==true)
                    {
                        if(list.indexForKey(searchCategory)==nil)
                        {
                            println("Required: \(searchCategory)")
                            list.updateValue( true , forKey: heirarchy.substringToIndex(idx))
                        }
                        end=true
                    }
                    
                    heirarchy.removeAtIndex(idx)
                    heirarchy=heirarchy.substringFromIndex(idx)
                    println("Heirarchy: \(heirarchy)")
                    
                }
                else
                {
                    if(found==true)  // Considers the last level listing. i.e the product itself
                    {
                        list.updateValue(true , forKey:heirarchy )
                        
                    }
                    //println("Not found")
                    end=true
                }
                println(heirarchy)
            }
            println(list.count)
            
        }
        for key in list.keys
        {
            nextSetOfCategories.append(key)
        }
        
        return nextSetOfCategories
    }
    */
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
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left && currentRoot != "All") {
            currentRoot = hierarchyStack.pop()
            navigationItem.title=currentRoot.stringByReplacingOccurrencesOfString(".", withString:" > ", options: NSStringCompareOptions.LiteralSearch, range: nil)
            categoryList = retrieveListing("\(currentRoot)")
            self.collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        leftSwipe.direction = .Left
        view.addGestureRecognizer(leftSwipe)
        
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
    }

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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CategoryViewCell
    
        var itemStr:String = (categoryList[indexPath.item][0]) as! String
        itemStr = itemStr.replace(".*\\.", template: "")
        
        cell.categoryNameLabel.text = "\(itemStr)"
        cell.categoryImage.image=UIImage(data: NSData(contentsOfURL: NSURL(string: (categoryList[indexPath.item][1]) as! String)!)!)
      
      
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
        
        hierarchyStack.push(currentRoot)
        currentRoot = (categoryList[indexPath.item][0]) as! String
        navigationItem.title=currentRoot.stringByReplacingOccurrencesOfString(".", withString:" > ", options: NSStringCompareOptions.LiteralSearch, range: nil)
        categoryList = retrieveListing("\(currentRoot)")
        self.collectionView?.reloadData()
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
