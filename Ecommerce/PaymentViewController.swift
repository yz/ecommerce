//
//  PaymentViewController.swift
//  Ecommerce
//
//  Created by Ashwinkarthik Srinivasan on 5/2/15.
//  Copyright (c) 2015 Ashwinkarthik Srinivasan. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController,PTKViewDelegate{

    var payBtn : UIBarButtonItem?
    var paymentView : PTKView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Stripe.setDefaultPublishableKey("pk_live_M8nQYLZJPzkC5ti2D3vasBZs")
        
        paymentView = PTKView(frame: CGRectMake(15, 20, 290, 55))
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
            }
        })
    }
    
    func handleToken(token: STPToken!) {
        //send token to backend and create charge
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
