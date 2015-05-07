//
//  FavoritesTableViewController.swift
//  TableTop
//
//  Created by Josh Ransom on 5/4/15.
//  Copyright (c) 2015 Josh Ransom. All rights reserved.
//

import UIKit
import Foundation
import FBSDKShareKit

protocol FavoritesTableViewControllerDelegate {
}

class FavoritesTableViewController: UITableViewController {
    var delegate: FavoritesTableViewControllerDelegate?
    var tableData = [Restaurant]()
    
     override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        loadFavorites()
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "User Favorites"
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        NSLog("LOAD TABLE: \(indexPath.row) : \(tableData[indexPath.row].restaurantName)")
       // var cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier("favcell") as RestaurantTableViewCell!
        let cell = tableView.dequeueReusableCellWithIdentifier("favcell", forIndexPath: indexPath) as RestaurantTableViewCell
       // if cell == nil{
           // cell = RestaurantTableViewCell(someRestaurant: tableData[indexPath.row] as Restaurant, p:self)
            cell.thisRestaurant = tableData[indexPath.row] as Restaurant
            cell.pReference = self
            cell.restName!.text = tableData[indexPath.row].restaurantName! as String
        //}
        //cell.textLabel?.textColor = UIColor.blackColor()
        //cell.restName?.text = tableData[indexPath.row].restaurantName
        
//            cell!.backgroundColor = UIColor.whiteColor()
//            let selectedView:UIView = UIView(frame: CGRect(x:0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
//            cell!.selectedBackgroundView  = selectedView
        
        return cell
    }
 
    func loadFavorites() {
        self.tableData = []
        var curruser = PFUser.currentUser()
        var favArray:[String] = curruser.valueForKey("Favorites") as [String]
        
        var query = PFQuery(className: "Restaurant")
        query.whereKey("objectId", containedIn: favArray)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error:NSError?) -> Void in
            
            if error == nil {
                println("SUCCESS")
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        var point = object.valueForKey("latLong") as PFGeoPoint
                        
                        var newPlace = Restaurant(name: object.valueForKey("restaurantName") as String, coordinate: CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude),id: object.objectId, startDate: object.valueForKey("eventDate") as NSDate)
                        NSLog("\(newPlace.restaurantName)")
                        self.tableData.append(newPlace)
                    }
                    self.tableView.reloadData()
                }
            } else {
                println("ERROR")
            }
        }
        NSLog("\(query)")
    }
    
    func attemptFBPost(restaurant: Restaurant)
    {
        var content = FBSDKShareLinkContent()
        content.contentTitle = "Is getting charitable at "+restaurant.restaurantName!
        content.contentURL = NSURL(string: "https://www.tabletop.com")
        content.contentDescription = "Introducing TableTop, an all new way to give charitably, while you do what you alread love doing - Eating at Restaurants"
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
        //}
    }
    
}

