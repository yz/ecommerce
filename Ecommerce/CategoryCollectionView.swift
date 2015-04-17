//
//  CategoryCollectionView.swift
//  Mobile Store
//
//  Created by Ashwinkarthik Srinivasan on 3/26/15.
//  Copyright (c) 2015 Yun Zhang. All rights reserved.
//

import UIKit
import Parse


class CategoryCollectionView: UICollectionViewController{
    
    
    var prodList : PFQuery!
    var categoryList = []
    var productList = []
    var currentCategory = ""
    
    func getSubCategoriesObjectIDs( productList: PFQuery) -> [[String]]{
        var ret: [[String]] = []
        
        for obj in productList.findObjects(){
            var inLst:[String] = []
            inLst.append(obj["Hierarchy"] as String)
            inLst.append(obj["itemImage"] as String)
            ret.append(inLst)
        }
        return ret
    }
    
    func isLastLevel( productList : PFQuery) -> Bool
    {
        var obj = productList.getFirstObject()
        
        if( productList.countObjects()==0)
        {
           return true;
        }
        else
        {
            return false;
        }
        
    }
    
    func isLastLevel( categoryName :String) -> Bool
    {
        
        
        var productList:PFQuery = PFQuery(className: "Product");
        //var matchPattern = ".*\(categoryName).*"
        var matchPattern = "\(categoryName)\\.[^\\.]*$"
        
        productList = productList.whereKey("Hierarchy", matchesRegex: matchPattern)
        if(productList.countObjects()==0)
        {
            return true;
        }
        else
        {
            return false;
        }
        
    }

    // Gets the next set of categories for the given input category
    func retrieveListing(categoryName :String) ->[[String]]{
        
        println("Retrieving list for \(categoryName)")
        var productList:PFQuery = PFQuery(className: "Product");
        
        
        //var matchPattern = ".*\(categoryName).*"
        var matchPattern = "\(categoryName)\\.[^\\.]*$"
        
        productList = productList.whereKey("Hierarchy", matchesRegex: matchPattern)  // retrieves the set of products that matched the input
    
        
        return getSubCategoriesObjectIDs(productList)
        //return getSubCategories(productList, categoryName : categoryName) // From the retrieved set of products gets the sub category list
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        
        let nibCategoryCell = UINib(nibName: "CategoryPrototypeCell", bundle: nil)
        collectionView?.registerNib(nibCategoryCell, forCellWithReuseIdentifier: "CategoryCell")
        
        Parse.setApplicationId("T5COsNbanlLkzcafpo6CkyeXlRNNvkL5RqQv8isL", clientKey: "n1Ko6El8LjehGEzZFSjDYFoCNSVt8tCMsJG0ftp5")
        if(currentCategory=="")
        {
            self.title = "Categories"
            currentCategory = "All"
            
        }
        if(prodList != nil)
        {
            println("Using data from the previous view controller")
            categoryList = getSubCategoriesObjectIDs(prodList)
        }
        else
        {
            categoryList = retrieveListing(currentCategory)
        }
        
        

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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(182,182)
    }

    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell : CategoryPrototypeCell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoryCell", forIndexPath: indexPath) as CategoryPrototypeCell
        
        cell.backgroundColor = UIColor.whiteColor()
        // Configure the cell
        var itemStr:String = (categoryList[indexPath.item][0]) as String
        itemStr = itemStr.replace(".*\\.", template: "")
        
        cell.categoryTitle.text = "\(itemStr)"
        cell.categoryImage.image=UIImage(data: NSData(contentsOfURL: NSURL(string: (categoryList[indexPath.item][1]) as String)!)!)

        
        return cell

        
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        var title = categoryList[indexPath.item][0] as String
        title = title.replace(".*\\.", template: "")
        
        var productList:PFQuery = PFQuery(className: "Product");
        //var matchPattern = ".*\(categoryName).*"
        var matchPattern = "\(title)\\.[^\\.]*$"
        productList = productList.whereKey("Hierarchy", matchesRegex: matchPattern)
        
        
        if(isLastLevel(productList))   // If its the last level load a different screen
        {
                println("Just before transition to last level")
                let productDetailView : ProductDetailViewController = ProductDetailViewController(nibName:"ProductDetailView",bundle:nil)
                productDetailView.title = title
                self.navigationController?.pushViewController(productDetailView, animated: true)
            

            return true
        }
        
        
            let nextCategoryLevel : CategoryCollectionView = CategoryCollectionView(nibName: "CategoryCollectionView", bundle: nil)
            nextCategoryLevel.prodList = productList
            nextCategoryLevel.title = title
            nextCategoryLevel.currentCategory = title
            nextCategoryLevel.categoryList = categoryList
        self.navigationController?.pushViewController(nextCategoryLevel, animated: true)
        
            return true
        
    }
    
    

    

}
