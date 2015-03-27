//
//  DummyViewController.swift
//  Mobile Store
//
//  Created by Ashwinkarthik Srinivasan on 3/26/15.
//  Copyright (c) 2015 Yun Zhang. All rights reserved.
//

import UIKit

class DummyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextCollectionLevel(sender: UIButton) {
        println("Inside ....")
        
        let nextLevel: CategoryCollectionView = CategoryCollectionView(nibName:"CategoryCollectionView", bundle:nil) as CategoryCollectionView
        
        nextLevel.title = "From Dummy View Controller"
        
        self.navigationController?.pushViewController(nextLevel, animated: false)
        
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
