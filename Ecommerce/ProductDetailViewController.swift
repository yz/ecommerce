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
    
    @IBAction func addToCart(sender: AnyObject) {
        
        if(PFUser.currentUser()==nil)
        {
            println("No user Logged in")
            
            let loginSignUpView : LoginSignUpViewController = LoginSignUpViewController(nibName:"LoginSignUpViewController",bundle:nil)
            self.navigationController?.pushViewController(loginSignUpView, animated: true)
            
            
        }
        else
        {
            println("You are \(PFUser.currentUser().username)")
        }
    }
    var object : PFObject!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(productTitle.text?)
        
        
    Parse.setApplicationId("T5COsNbanlLkzcafpo6CkyeXlRNNvkL5RqQv8isL", clientKey: "n1Ko6El8LjehGEzZFSjDYFoCNSVt8tCMsJG0ftp5")
       
        var reqObject:PFQuery = PFQuery(className: "Product");
        var matchPattern = ".*\(self.title!)"
        
        reqObject = reqObject.whereKey("Hierarchy", matchesRegex: matchPattern)
        
        var imageLink = reqObject.getFirstObject()["itemImage"] as String
        
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
