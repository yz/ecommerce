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
    
    @IBOutlet var addToCart: UIButton!
    
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
            //println("You are \(currentUser.username)")
            if addItemToCart(currentUser["email"] as String, path: hierarchy){
                addToCart.setTitle("Added to Cart", forState: UIControlState.Normal)
            }
        }
        
        var reqObject:PFQuery = PFQuery(className: "Product");
        var matchPattern = ".*\(self.title!)"
        reqObject = reqObject.whereKey("Hierarchy", matchesRegex: matchPattern)
        var obj = reqObject.getFirstObject()
        if (obj["count"] as Int) < 1{//Nothing left
            addToCart.enabled = false
        }
        productTitle.text = self.title! + "( " + String(obj["count"] as Int) + " )"
    }
    
    
    func addItemToCart(usr:String, path:String)->(Bool){
        var added:Bool = false
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
            }
            var cart:PFObject = cartList.getFirstObject() as PFObject
            var currCart:PFRelation = cart.relationForKey("Product")
            
            for obj in productList.findObjects(){
                row = obj as PFObject
                if row["productType"] as Int == 1 && row["count"] as Int > 0{//Valid item selected, add to cart
                    /*
                    var added:Bool = false
                    var cartQuery:PFQuery = currCart.query().whereKey("Hierarchy", equalTo: row["Hierarchy"] as NSString)
                    for exitingObj in cartQuery.findObjects(){
                        let eO = exitingObj as PFObject
                        currCart.removeObject(eO)
                        eO["count"] = eO["count"] as Int + 1
                        currCart.addObject(eO)
                        added = true
                        break
                    }
                    
                    if !added{//Add fresh.
                        println("Adding a new cart object.")
                        currCart.addObject(row)
                    }
                    */                    
                    row["count"] = row["count"] as Int - 1
                    /*var anyob = PFObject(className: "Product")
                    anyob[row["Hierarchy"] as NSString] = 100
                    cart["count"] = anyob*/
                    let cnt:String = cart["count"] as String
                    var res:String = ""
                    var found:Bool = false
                    for keyval in cnt.componentsSeparatedByString("%"){
                        if !keyval.isEmpty{
                            let kv:[String] = keyval.componentsSeparatedByString("=")
                            var k = kv[0]
                            var v = kv[1]
                            if k == row["Hierarchy"] as String{
                                v = String(v.toInt()! + 1)
                                found = true
                            }
                            
                            if res.isEmpty{
                                res = k + "=" + v
                            }else{
                                res = res + "%" + k + "=" + v
                            }
                        }
                    }
                    
                    if found{
                        cart["count"] = res
                    }
                    else{
                        if res.isEmpty{
                            cart["count"] = (row["Hierarchy"] as String) + "=1"
                        }else{
                            cart["count"] = res + "%" + (row["Hierarchy"] as String) + "=1"
                        }
                    }
                    
                    /*
                    if let isCount = cart["count"] as NSDictionary?{
                        //Do nothing
                    }else{
                        cart["count"] = [row["Hierarchy"] as NSString : 0]
                    }
                    cart["count"] = cart["count"][row["Hierarchy"] as NSString] as Int + 1*/
                    currCart.addObject(row)
                    row.saveInBackgroundWithBlock(nil)
                    cart.save()
                    added = true
                    println("Saved objects")
                }
            }
        }
        
        return added
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
        productTitle.text = self.title! + "( " + String(obj["count"] as Int) + " )"
        if (obj["count"] as Int) < 1{// Only one item left
            addToCart.enabled = false
        }
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
