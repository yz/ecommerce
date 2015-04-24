//
//  ProductDetailViewController.swift
//  Mobile Store
//
//  Created by Ashwinkarthik Srinivasan on 4/2/15.
//  Copyright (c) 2015 Yun Zhang. All rights reserved.
//

import UIKit
import Parse

class ProductDetailViewController: UIViewController {

    
    
    @IBOutlet var productImage: UIImageView!
    
    
    @IBOutlet var productTitle: UILabel!
    
    var hierarchy : String = ""
    
    @IBAction func addToCart(sender: AnyObject) {
        
        if(PFUser.currentUser()==nil)
        {
            println("No user Logged in")
            
            let loginSignUpView : LoginSignUpViewController = LoginSignUpViewController(nibName:"LoginSignUpViewController",bundle:nil)
            self.navigationController?.pushViewController(loginSignUpView, animated: true)
            
            
        }
        else
        {
            let currentUser = PFUser.currentUser()
            currentUser.fetch()
            println("You are \(currentUser.username)")
            addItemToCart(currentUser["email"] as String, path: hierarchy)
        }
    }
    
    
    func addItemToCart(usr:String, path:String)->(){
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
            var cart:PFObject = cartList.getFirstObject() as PFObject
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(productTitle.text?)
        
        
    Parse.setApplicationId("T5COsNbanlLkzcafpo6CkyeXlRNNvkL5RqQv8isL", clientKey: "n1Ko6El8LjehGEzZFSjDYFoCNSVt8tCMsJG0ftp5")
       
        var reqObject:PFQuery = PFQuery(className: "Product");
        var matchPattern = ".*\(self.title!)"
        
        reqObject = reqObject.whereKey("Hierarchy", matchesRegex: matchPattern)
        var obj = reqObject.getFirstObject()
        var imageLink = obj["itemImage"] as String
        hierarchy = obj?["Hierarchy"] as String
        
        println("-----------> " + hierarchy)
        productImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: imageLink)!)!)
        productTitle.text = self.title!
        

        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
