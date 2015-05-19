//
//  DummyViewController.swift
//  Mobile Store
//
//  Created by Ashwinkarthik Srinivasan on 3/26/15.
//  Copyright (c) 2015 Yun Zhang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class DummyViewController: UIViewController,PTKViewDelegate {

    var paymentView : PTKView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paymentView = PTKView(frame: CGRectMake(0, 20, 290, 55))
        paymentView?.center = view.center
        paymentView?.delegate = self
        view.addSubview(paymentView!)
       

        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextCollectionLevel(sender: UIButton) {
        println("Inside ....")
        
        
        let shoppingCart : ShoppingCartViewController = ShoppingCartViewController(className: "Cart")   
        self.navigationController?.pushViewController(shoppingCart, animated: false)
        
        
        self.addChildViewController(shoppingCart)
        
        /*
        let shoppingCart : CategoryCollectionView = CategoryCollectionView(nibName: "CategoryCollectionView", bundle: nil)
        self.navigationController?.pushViewController(shoppingCart, animated: false)
        */
        shoppingCart.title = "Shopping Cart"
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
