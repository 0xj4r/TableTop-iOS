//
//  TableTopLoginView.swift
//  TableTop
//
//  Created by Josh Ransom on 11/28/14.
//  Copyright (c) 2014 Josh Ransom. All rights reserved.
//

import UIKit
import Foundation
import FBSDKLoginKit
import FBSDKCoreKit

class TableTopLoginView: PFLogInViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logInView.logo = UIImageView(image: UIImage(named: "TTLogoGimp.png"))
        self.logInView.backgroundColor = colorize(0xED8337, alpha: 1.0)
            //UIColor(red: 237, green: 131, blue: 55, alpha: 1)
       self.logInView.logo.sizeThatFits(CGSizeMake(self.view.frame.width, 250))

    }
    
    func _loginWithFacebook() {
        println("hello")
        FBSDKLoginManager().logInWithReadPermissions([], handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                //error
            }else if result.isCancelled{
                //cancelled
            }else{
                //success
                println("FBLOGIN Success")
                FBSDKAccessToken.setCurrentAccessToken(result.token)
                Globals.global.currentToken = result.token
                println(Globals.global.currentToken)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        var i = 110
        self.logInView.dismissButton.layer.zPosition = 1
        self.logInView.dismissButton.frame = CGRectMake(10, 20, self.logInView.dismissButton.frame.width * 0.5, self.logInView.dismissButton.frame.height * 0.5)
        self.logInView.logo.frame = CGRectMake(0, CGFloat(i - 100), self.view.frame.width, 250)
        self.logInView.usernameField.frame = CGRectMake(0, CGFloat(145+i), self.view.frame.width, 50)
        self.logInView.passwordField.frame = CGRectMake(0, CGFloat(195+i), self.view.frame.width, 50)
        self.logInView.logInButton.frame = CGRectMake(0, CGFloat(i + 245), self.view.frame.width, 50)
        self.logInView.passwordForgottenButton.frame = CGRectMake(0, CGFloat(300 + i), self.view.frame.width, 30)
        //        CGRect
        //        self.logInView.frame = CGRectMake(35.0, 145.0, 250.0, 100.0)
    }

    
    // colorize function takes HEX and Alpha converts then returns aUIColor object
    func colorize (hex: Int, alpha: Double = 1.0) -> UIColor {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0xFF00) >> 8) / 255.0
        let blue = Double((hex & 0xFF)) / 255.0
        var color: UIColor = UIColor( red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha:CGFloat(alpha))
        return color
    }
}
