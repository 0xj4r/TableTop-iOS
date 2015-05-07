//
//  SideBarTableViewController.swift
//  TableTop
//
//  Created by Josh Ransom on 9/7/14.
//  Copyright (c) 2014 Josh Ransom. All rights reserved.
//

import UIKit


protocol SideBarTableViewControllerDelegate{
    func sideBarControlDidSelectRow(indexPath:NSIndexPath)
}
    
class SideBarTableViewController: UITableViewController {
    var delegate:SideBarTableViewControllerDelegate?
    var tableData:Array<String> = []
    
    override func numberOfSectionsInTableView(tableView: (UITableView!)) -> Int {
        return 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("Loaded Table")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func tableView(tableView:(UITableView!), numberOfRowsInSection section: Int) -> Int {
        NSLog("NUM OF ROWS : \(tableData.count))")
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return tableData.count
    }

    
    override func tableView(tableView:(UITableView!), cellForRowAtIndexPath indexPath: (NSIndexPath!)) -> UITableViewCell {        /// Configure the cell...
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            cell?.textLabel?.textColor = UIColor.blackColor()
            cell?.textLabel?.text = tableData[indexPath.row]
            cell!.backgroundColor = UIColor.clearColor()
            let selectedView:UIView = UIView(frame: CGRect(x:0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
            cell!.selectedBackgroundView  = selectedView
        }
               return cell!
    }


    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("Selected Row")
        delegate?.sideBarControlDidSelectRow(indexPath)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Restaurants"
    }
    
    
}
