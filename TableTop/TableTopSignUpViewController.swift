//
//  TableTopSignUpViewController.swift
//  TableTop
//
//  Created by Josh Ransom on 11/28/14.
//  Copyright (c) 2014 Josh Ransom. All rights reserved.
//
import UIKit
import Foundation

class TableTopSignUpViewController: PFSignUpViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signUpView.logo = UIImageView(image: UIImage(named: "TTLogoGimp.png"))
        self.signUpView.backgroundColor = colorize(0xED8337, alpha: 1.0)
        self.signUpView.logo.sizeThatFits(CGSizeMake(self.view.frame.width, 250))
        
        
    }
    
    override func viewDidLayoutSubviews() {
        var i = 110
        self.signUpView.dismissButton.layer.zPosition = 1
        self.signUpView.dismissButton.frame = CGRectMake(10, 20, self.signUpView.dismissButton.frame.width * 0.5, self.signUpView.dismissButton.frame.height * 0.5)
        self.signUpView.logo.frame = CGRectMake(0, CGFloat(i - 100), self.view.frame.width, 250)
        self.signUpView.usernameField.frame = CGRectMake(0, CGFloat(145+i), self.view.frame.width, 50)
        self.signUpView.passwordField.frame = CGRectMake(0, CGFloat(195+i), self.view.frame.width, 50)
        self.signUpView.emailField.frame = CGRectMake(0, CGFloat(245+i), self.view.frame.width, 50)
        self.signUpView.signUpButton.frame = CGRectMake(0, CGFloat(310 + i), self.view.frame.width, 50)
        
        //        CGRect
        //        self.signUpView.frame = CGRectMake(35.0, 145.0, 250.0, 100.0)
    }
    
    
    // colorize function takes HEX and Alpha converts then returns aUIColor object
    func colorize (hex: Int, alpha: Double = 1.0) -> UIColor {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0xFF00) >> 8) / 255.0
        let blue = Double((hex & 0xFF)) / 255.0
        var color: UIColor = UIColor( red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha:CGFloat(alpha) )
        return color
    }


}
