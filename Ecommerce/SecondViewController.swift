//
//  SecondViewController.swift
//  Mobile Store
//
//  Created by Yun Zhang on 2/27/15.
//  Copyright (c) 2015 Yun Zhang. All rights reserved.
//

import UIKit
import Parse

class SecondViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    var loginViewController : CustomPFLogInViewController = CustomPFLogInViewController()
    var signupViewController : PFSignUpViewController = PFSignUpViewController()
    
    @IBOutlet var btnLogoutObj: UIButton!
    
    @IBOutlet weak var btnDeleteUsr: UIButton!
    
    @IBAction func btnLogout(sender: AnyObject) {
        if let tmp = PFUser.currentUser()
        {
            PFUser.logOut()
        }
        loginNewOrLogout()
    }
    
    @IBAction func btnDeleteAccount(sender: AnyObject) {
        if let currentUser = PFUser.currentUser()
        {
            currentUser.fetch()
            var users:PFQuery = PFQuery(className: "_User");
            users = users.whereKey("email" , matchesRegex: currentUser["email"] as String)
            
            if(users.countObjects() != 0 && currentUser.isAuthenticated()){//Object exists
                for usr in users.findObjects(){
                    usr.deleteInBackgroundWithBlock(nil)
                }
            }
            
            PFUser.logOut()
        }
        loginNewOrLogout()
    }
    
    
    func loginNewOrLogout(){
        if PFUser.currentUser()==nil
        {
            loginViewController.logInView.passwordField.text = ""
            self.presentViewController(loginViewController, animated: true, completion: nil)
        }else{
            if let verified = PFUser.currentUser().objectForKey("emailVerified") as? Bool{
                if verified{
                    btnLogoutObj.setTitle("Logout \(PFUser.currentUser().username)", forState: nil)
                    btnDeleteUsr.setTitle("Delete \(PFUser.currentUser().username)", forState: nil)
                    return
                }
            }
            
            PFUser.logOut()
            var alert = UIAlertView(title: "First-time Login", message: "Please verify your e-mail before logging in", delegate: self, cancelButtonTitle: "Ok")
            alert.show()
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
    
    override func viewDidAppear(animated: Bool) {
        loginNewOrLogout()
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

