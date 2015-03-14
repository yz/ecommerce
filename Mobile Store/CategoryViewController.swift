//
//  CategoryViewController.swift
//  Mobile Store
//
//  Created by Ashwinkarthik Srinivasan on 3/6/15.
//  Copyright (c) 2015 Yun Zhang. All rights reserved.
//

import UIKit

let reuseIdentifier = "CategoryCell"

var categoryList = ["Category-1","Category-2","category-3"]

var subCategoryList=[["SubCategory-01","SubCategory-02","SubCategory-03"],["SubCategory-11","SubCategory-12","SubCategory-13"],["SubCategory-21","SubCategory-22","SubCategory-23"]]

var categorySelected : Int = -1

class CategoryViewController: UICollectionViewController {
    var myImage = UIImage(named: "Apple_Swift_Logo")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title="WAR"

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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as CategoryViewCell
    

      if(categorySelected == -1)
      {
        cell.categoryNameLabel.text = "\(categoryList[indexPath.item])"
        
        
        cell.categoryImage.image=myImage
      }
      else
      {
        cell.categoryNameLabel.text = "\(subCategoryList[categorySelected][indexPath.item])"
        cell.backgroundColor = UIColor.redColor()
        
      }
        
        
    
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
        
        
        categorySelected = indexPath.item
        println(indexPath.item)
        //hierarchy.append(categorySelected)
        self.collectionView?.reloadData()
        //var vc = CategoryViewController(nibName: "CategoryViewController", bundle: nil)
        //navigationController?.pushViewController(vc, animated: false)
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
