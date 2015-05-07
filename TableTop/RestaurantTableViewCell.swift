//
//  RestaurantTableViewCell.swift
//  TableTop
//
//  Created by Tim Ferguson on 5/6/15.
//  Copyright (c) 2015 Josh Ransom. All rights reserved.
//

import UIKit
import EventKit
import FBSDKShareKit
import Foundation

class RestaurantTableViewCell: UITableViewCell {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    let eventStore = EKEventStore()
    var thisRestaurant: Restaurant?
    var pReference: FavoritesTableViewController?
    @IBOutlet var restName: UILabel?
    override init()
    {
        super.init()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override init(frame: CGRect) {
        //thisRestaurant = Restaurant(name: "something", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        super.init(frame: frame)
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    @IBAction func addEvent(sender: UIButton) {
        addEventToCal(thisRestaurant!)
    }
    
    @IBAction func shareTofacebook(sender: UIButton) {
        self.pReference!.attemptFBPost(thisRestaurant!)
    }
    
    func addEventToCal(selectedRestaurant: Restaurant)
    {
        switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent){
        case .Authorized:
            insertEvent(self.eventStore,  event: selectedRestaurant)
        case .Denied:
            println("Access Denied")
        case .NotDetermined:
            eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion:
                {[weak self] (granted: Bool, error: NSError!) -> Void in
                    if granted {
                        self!.insertEvent(self!.eventStore, event: selectedRestaurant)
                    } else {
                        println("Access denied")
                    }
            })
        default:
            println("Defaults on switch-case")
            
        }
    }
    
    func insertEvent(store: EKEventStore, event: Restaurant)
    {
        let calendars = store.calendarsForEntityType(EKEntityTypeEvent) as [EKCalendar]
        
        for calendar in calendars {
            
            //if calendar.title == "ioscreator"
            //{
            let startDate = event.beginDate
            let endDate = startDate?.dateByAddingTimeInterval(2*60*60)
            var calEvent = EKEvent(eventStore: store)
            calEvent.calendar = calendar
            calEvent.title = event.restaurantName!
            calEvent.startDate = startDate
            calEvent.endDate = endDate
            
            var error: NSError?
            let result = store.saveEvent(calEvent, span: EKSpanThisEvent, error: &error)
            
            if result == false{
                if let theError = error{
                    println("an error occured \(theError)")
                }
            }
            
            // }
        }
    }

    

 
   
}
