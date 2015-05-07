//
//  RestaurantTableController.swift
//  TableTop
//
//  Created by Josh Ransom on 5/4/15.
//  Copyright (c) 2015 Josh Ransom. All rights reserved.
//


import UIKit
import Foundation
import FBSDKShareKit

protocol RestaurantTableControllerDelegate {
    
}

class RestaurantTableController: UITableViewController {
    var delegate:RestaurantTableControllerDelegate?
    var tableData = [Restaurant]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Restaurants"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("Selected Row : \(indexPath.row)")
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
//        if cell == nil {
//            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
//            cell?.textLabel?.textColor = UIColor.blackColor()
//            cell?.textLabel?.text = tableData[indexPath.row].restaurantName
//            cell!.backgroundColor = UIColor.whiteColor()
//            let selectedView:UIView = UIView(frame: CGRect(x:0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
//            //selectedView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
//            cell!.selectedBackgroundView  = selectedView
//        }
//        return cell!
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as OtherRestTableViewCell
        cell.thisRestaurant = tableData[indexPath.row]
        cell.restName!.text = tableData[indexPath.row].restaurantName!
        cell.pReference = self
        return cell
    }
    
    func attemptFBPost(restaurant: Restaurant)
    {
        var content = FBSDKShareLinkContent()
        content.contentTitle = "Get charitable at "+restaurant.restaurantName!
        content.contentURL = NSURL(string: "https://www.tabletop.com")
        content.contentDescription = "Introducing TableTop, an all new way to give charitably, while you do what you alread love doing - Eating at Restaurants"
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
        //}
    }
    

    
    
}
