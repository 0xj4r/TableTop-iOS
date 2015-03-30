//
//  NavigationController.swift
//  TableTop
//
//  Created by Josh Ransom on 10/29/14.
//  Copyright (c) 2014 Josh Ransom. All rights reserved.
//

import Foundation
import UIKit



class NavigationController: UINavigationController, UIViewControllerTransitioningDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = UIColor.whiteColor()
        
    }
}