//
//  PaymentViewController.swift
//  Ecommerce
//
//  Created by Ashwinkarthik Srinivasan on 5/2/15.
//  Copyright (c) 2015 Ashwinkarthik Srinivasan. All rights reserved.
//

import UIKit
import Parse

class PaymentViewController: UIViewController,PTKViewDelegate{

    var payBtn : UIBarButtonItem?
    var paymentView : PTKView?
    var price: Float64 = 0.0
    var result: Bool = false
    var parent:ShoppingCartViewController?
    
    func PaymentViewController(parent:ShoppingCartViewController, price:Float64){
        self.parent = parent
        self.price = price
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Stripe.setDefaultPublishableKey("pk_live_M8nQYLZJPzkC5ti2D3vasBZs")
        Stripe.setDefaultPublishableKey("pk_test_gc5Hmze7imzY3TifemNrXuF8") //Mine(Sarath)
        
        paymentView = PTKView(frame: CGRectMake(0, 20, 290, 55))
        paymentView?.center = view.center
        paymentView?.delegate = self
        view.addSubview(paymentView!)
        
        payBtn = UIBarButtonItem(title: "Pay", style: UIBarButtonItemStyle.Plain, target: self, action: "createToken")
        payBtn!.enabled = false
        navigationItem.rightBarButtonItem = payBtn
        
    }
    
    func paymentView(paymentView: PTKView!, withCard card: PTKCard!, isValid valid: Bool) {
        
        payBtn!.enabled = valid
        println("Is valid: ")
        println(valid)
    }
    
    func createToken() {
        
        let card = STPCard()
        card.number = paymentView!.card.number
        card.expMonth = paymentView!.card.expMonth
        card.expYear = paymentView!.card.expYear
        card.cvc = paymentView!.card.cvc
        
        STPAPIClient.sharedClient().createTokenWithCard(card, completion: { (token: STPToken!, error: NSError!) -> Void in
            if (error != nil) {
                println(error)
            } else {
                println(token)
                self.handleToken(token)
            }
        })
    }
    
    func handleToken(token: STPToken!) {
        //send token to backend and create charge
        //var result: Bool = PFCloud.callFunction("chargeCard", withParameters: ["price": self.price, "cardToken": "INVALID_TOKEN_ID"]) as Bool//FOR FAILURE ONLY! REMOVE IT.
        self.result = PFCloud.callFunction("chargeCard", withParameters: ["price": self.price, "cardToken": token.tokenId]) as Bool
        println("Charging is successful = \(self.result)")
        var alert = UIAlertController(title: "Payment Information", message: self.result ? "Success! $\(self.price) has been charged to your account." : "Sorry, the payment failed. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { action in
            println("Ok")
            self.parent?.clearShoppingCart()
            self.navigationController?.popViewControllerAnimated(true)
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
