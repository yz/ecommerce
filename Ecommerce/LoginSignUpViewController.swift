//
//  LoginSignUpViewController.swift
//  Ecommerce
//
//  Created by Ashwinkarthik Srinivasan on 4/22/15.
//  Copyright (c) 2015 Ashwinkarthik Srinivasan. All rights reserved.
//

import UIKit
import Parse

class LoginSignUpViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    var loginViewController : CustomPFLogInViewController = CustomPFLogInViewController()
    var signupViewController : PFSignUpViewController = PFSignUpViewController()
    
    
    @IBOutlet var btnLogout: UIButton!
   
    @IBOutlet var userName: UILabel!
    
    @IBAction func btnLogout(sender: AnyObject) {
        if let tmp = PFUser.currentUser()
        {
            PFUser.logOut()
        }
        loginNewOrLogout()
    }
    
    
    
    func loginNewOrLogout(){
        if PFUser.currentUser()==nil
        {
            loginViewController.logInView.passwordField.text = ""
            self.presentViewController(loginViewController, animated: false, completion: nil)
        }else{
            btnLogout.setTitle("Logout \(PFUser.currentUser().username)", forState: nil)
            userName.text = PFUser.currentUser().username as String
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginViewController.delegate = self
        self.signupViewController.delegate = self
        self.loginViewController.signUpController = signupViewController
        
        let newLogoLogin  = UILabel()
        newLogoLogin.text = "MobileWare"
        self.loginViewController.fields =  PFLogInFields.PasswordForgotten | PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.SignUpButton
        self.loginViewController.logInView.logo = newLogoLogin
        let newLogoSignup  = UILabel()
        newLogoSignup.text = "MobileWare"
        self.signupViewController.signUpView.logo = newLogoSignup
        //loginNewOrLogout()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func setShoppingCartBadgeCount()
    {
        let shoppingCart : ShoppingCartViewController = ShoppingCartViewController(className: "Cart")
        var tabBarItem = self.tabBarController?.tabBar.items?.last as UITabBarItem
        var count = shoppingCart.getNumOfItems()
        if count>0
        {
            tabBarItem.badgeValue = "\(count)"
        }
        else
        {
            tabBarItem.badgeValue = nil
        }
    }
    override func viewWillAppear(animated: Bool) {
        loginNewOrLogout()
        setShoppingCartBadgeCount()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
        
        return true
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        
        self.dismissViewControllerAnimated( true, completion: nil)
        loginNewOrLogout()
    }
    
    
    func  logInViewController(logInController: PFLogInViewController!, didFailToLogInWithError error: NSError!) {
        
        var alert = UIAlertView(title: "Login Error", message: "Enter Valid User Id and Password", delegate: self, cancelButtonTitle: "Ok")
        alert.show()
        
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, shouldBeginSignUp info: [NSObject : AnyObject]!) -> Bool {
        println("shouldBeginSignUp---------")
        return true
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        println("didSignUpUser---------")
        if PFUser.currentUser()==nil
        {
            PFUser.logOut()
        }
        signUpController.dismissViewControllerAnimated( true, completion: nil)
        loginNewOrLogout()
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        
    }
    
    
}

