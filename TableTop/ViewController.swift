//
//  ViewController.swift
//  TableTop
//
//  Created by Josh Ransom on 9/7/14.
//  Copyright (c) 2014 Josh Ransom. All rights reserved.
//


/// App Todo: 
/*
    * Create TT Map Icon
    * Integrate Yelp API for locations
    * Setup user Account functionality for application
    * Setup firebasedb for accounts and events
    * Add Initial Screen (TT Logo) 
    * Add TableTokens Page / Account Management (apple pay?)    
*/

import UIKit
import MapKit
import CoreLocation
import MobileCoreServices
import Social
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit
import EventKit

class ViewController: UIViewController, SideBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, RestaurantTableControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    var sideBar:SideBar = SideBar()
    var cllManager = CLLocationManager()
    var locDelegate:CLLocationManagerDelegate!
    var mapKitRestaurauntResponse = [Restaurant]()
    var parseRestaurantResponses = [Restaurant]()
    var mergedRestaurauntsList = [Restaurant]()
    var searchRadius = Double()
    var accessToken = FBSDKAccessToken()
    struct accessT{
        static var currentToken = FBSDKAccessToken()
    }
    let eventStore = EKEventStore()

    var barMenu = ["Josh Ransom", "Balance: 45.00", "Account", "Charities", "Events"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        cllManager.desiredAccuracy = kCLLocationAccuracyBest
        cllManager.distanceFilter = 100.0 // 100 meters between updates.
        cllManager.requestWhenInUseAuthorization()
        cllManager.startUpdatingLocation()
        sideBar.sideBarTableViewController.tableData = barMenu
        
        checkForCurrentUser()
        searchRadius = 5.0
        
        var latDelta:CLLocationDegrees = 0.01
        var longDelta:CLLocationDegrees = 0.01
        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)

        
        var tab =  self.tabBarController?.tabBar
        tab?.tintColor = UIColor.whiteColor()
        

        
        sideBar = SideBar(sourceView: self.view, menuItems: barMenu)
        sideBar.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        self.searchBar.delegate = self


    }

        func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
            if (username != nil && password != nil) {
               // attemptFBLogin()
                return true
            }
            var alert = UIAlertView(title: "Missing Information", message: "Make sure you fill out all of the information", delegate: nil, cancelButtonTitle: "ok", otherButtonTitles: "")
            alert.show()
            return false
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sideBarDidSelectButtonAtIndex(index: Int) {
        if index == 0 {
            NSLog("INDEX 0")
        } else if index == 1{
                  }
    }
    
    @IBAction func searchBarButtonClicked(sender: UIBarButtonItem) {
        if self.searchBar.hidden {
            updateUserLocation()
            self.searchBar.becomeFirstResponder() // Automatically prepare to edit text
            self.searchBar.hidden = false
            NSLog("Not Hidden")
        } else {
            self.searchBar.hidden = true
            searchBar.resignFirstResponder()
            NSLog("Hidden")
        }
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        self.mapView.setRegion(MKCoordinateRegionMake(self.mapView.userLocation.coordinate, MKCoordinateSpanMake(0.0081, 0.0081)), animated: true)
    }
        // Not used.
    
    @IBAction func openMenu(sender: UIBarButtonItem) {
        if sideBar.isSideBarOpen{
            sideBar.showSideBar(false)
        }
        else {
            sideBar.showSideBar(true)
        }
    }

    func checkForCurrentUser() {
        if(PFUser.currentUser() == nil){
            var logInViewController = TableTopLoginView()
            var signUpViewController = TableTopSignUpViewController ()
            logInViewController.delegate = self
            signUpViewController.delegate = self
            logInViewController.signUpController=signUpViewController
            logInViewController.fields = PFLogInFields.Default | PFLogInFields.Twitter | PFLogInFields.Facebook | PFLogInFields.DismissButton | PFLogInFields.SignUpButton
            self.presentViewController(logInViewController, animated: true , completion: nil)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        mergedRestaurauntsList.removeAll(keepCapacity: false)
        setRadiusValue()
        
        sideBar.sideBarTableViewController.tableView.reloadData()
        
        
        var searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = self.searchBar.text
        var requestToQueryParse = self.searchBar.text
        searchRequest.region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, MilesToMeters(searchRadius), MilesToMeters(searchRadius))
        var localSearch = MKLocalSearch(request: searchRequest)
        var searchResponse = MKLocalSearchResponse()
        var mapError = NSError()
        localSearch.startWithCompletionHandler(searchResultsHandler)
    }
    
    @IBAction func viewTapped(sender: AnyObject) {
        searchBar.resignFirstResponder()
    }
    
   
    
    

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation.isKindOfClass(MKUserLocation)){
            return nil
        }
        if(annotation.isKindOfClass(MKPointAnnotation)) {
            var pinView = TTAnnotationView( annotation: annotation, reuseIdentifier: "CustomPinAnnotationView")
            var thisRest:Restaurant?
            for each:Restaurant in mergedRestaurauntsList {
                if each.restaurantCoordinate?.latitude == annotation.coordinate.latitude && each.restaurantCoordinate?.longitude == annotation.coordinate.longitude {
                    NSLog("GOT IT")
                        NSLog("\(each.restaurantName)")
                    thisRest = each
                }
            }
            pinView.canShowCallout = true
            pinView.restaurant = thisRest
            var annotationIcon = UIImage(named: "tabletopmapicon.png")
            pinView.image = annotationIcon
            pinView.calloutOffset = CGPointMake(0, 0)
            pinView.tintColor = UIColor.lightGrayColor()
            var favoritesImage = UIImage(named: "checkedStar.png")
            var frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            var buttonView = UIView(frame: frame)
            var favButton:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
            favButton.setImage(favoritesImage, forState: .Normal)
            favButton.setImage(UIImage(named: "uncheckedStar.png"), forState: UIControlState.Selected)
            buttonView.addSubview(favButton as UIView)
            pinView.leftCalloutAccessoryView = favButton
            pinView.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.ContactAdd) as UIButton
            return pinView
        }
        return  nil
    }
    // Add items to list when searched.
    // Add items to map when searched.
    func searchResultsHandler(response: MKLocalSearchResponse!, error: NSError!) -> Void {
        self.mapView.removeAnnotations(self.mapView.annotations!)
        mapKitRestaurauntResponse.removeAll(keepCapacity: false)
        buildAndSendParseQueryForLocations()
        if let gotError = error {
            println("Error in Search")
        }
        else
        {
            var placemarks:[CLPlacemark] = []
            var items: [MKMapItem] = response.mapItems as [MKMapItem]
            var intCount = 0
            for each in items {
                var id = "id \(intCount)"
                var restaurant = Restaurant(name: each.name!, coordinate: each.placemark.coordinate)
                mapKitRestaurauntResponse.append(restaurant)
                intCount++
            }
        }
    }
    
    
    
    //ask parse for items near user
    func buildAndSendParseQueryForLocations() -> Void {
        parseRestaurantResponses.removeAll(keepCapacity: false)
        mergedRestaurauntsList.removeAll(keepCapacity: false)
        var query = PFQuery(className: "Restaurant")
        var location = self.mapView.userLocation.coordinate
        var geoPointCoordinate = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        query.whereKey("latLong", nearGeoPoint: geoPointCoordinate, withinMiles: MilesToMeters(searchRadius))
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects.count) map items.")
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        println(object.objectId)
                        var geoPoint = object.objectForKey("latLong") as PFGeoPoint!
                        var coordinateForRestaurant = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                        var date = object.valueForKey("eventDate") as NSDate
                        var restaurant = Restaurant(name: object.valueForKey("restaurantName") as String!, coordinate: coordinateForRestaurant, id: object.objectId, startDate: date)
                        self.parseRestaurantResponses.append(restaurant)
                    }
                    self.mergeListsToFindCommonResults()
                }
            }
            else {
                // Log details of the failure
                println("Error: \(error) \(error.userInfo!)")
            }
        }
    }


    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        NSLog("BAR")
        if control == annotationView.leftCalloutAccessoryView {
            NSLog("Left Click")
        } else {
            if annotationView.isMemberOfClass(TTAnnotationView) {
                var TTView:TTAnnotationView = annotationView as TTAnnotationView
                NSLog("RIGHT CLICK")
                NSLog("\(TTView.restaurant?.restaurantName)")
                addToUserFavorites(TTView.restaurant!)
                annotationView.rightCalloutAccessoryView.hidden = true
            }
        }
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        self.dismissViewControllerAnimated(true , completion: nil)
    }
    func logInViewController(logInController: PFLogInViewController!, didFailToLogInWithError error: NSError!) {
        NSLog("Could not log in. Please try again")
    }
    func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        self.dismissViewControllerAnimated(true , completion: nil)
    }
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        NSLog("Failed to Signup")
    }
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController!) {
        NSLog("User dismissed signup")
    }

    
    //combine found lists of items
    func mergeListsToFindCommonResults()
    {
        self.mergedRestaurauntsList.removeAll(keepCapacity: false)
        NSLog("MERGED COUNT: 292: \(mergedRestaurauntsList.count)")
        for pRest in parseRestaurantResponses
        {
            var pRestLoc = CLLocation(latitude: pRest.restaurantCoordinate!.latitude, longitude: pRest.restaurantCoordinate!.longitude)
            for mRest in mapKitRestaurauntResponse
            {
                //if pRest.restaurantName! == mRest.restaurantName!{
                var mRestLoc = CLLocation(latitude: mRest.restaurantCoordinate!.latitude, longitude: mRest.restaurantCoordinate!.longitude)
                var dist = pRestLoc.distanceFromLocation(mRestLoc)
                if (dist < 20.0 ){
                    mergedRestaurauntsList.append(pRest)
                    if let indexToRemove = find(parseRestaurantResponses, pRest) as Int!
                    {
                        parseRestaurantResponses.removeAtIndex(indexToRemove)
                    }
                }
            }
        }
        plotCommonRestaurants();
    }
    
    //put the items on the map
    func plotCommonRestaurants(){
        self.mapView.removeAnnotations(self.mapView.annotations!)
        for restaurant in mergedRestaurauntsList
        {
            var myAnnotation = TTPointAnnotation()
            myAnnotation.title = restaurant.restaurantName
            myAnnotation.coordinate = restaurant.restaurantCoordinate!
            var annoView = MKPinAnnotationView(annotation: myAnnotation, reuseIdentifier: restaurant.uniqueId!)
            self.mapView.viewForAnnotation(myAnnotation)
            self.mapView.addAnnotation(myAnnotation)
        }
        addEventToCal(mergedRestaurauntsList.first!)
        
    }
    
    func MilesToMeters(miles : Double) -> CLLocationDistance{
        return (1609.344  * miles) as CLLocationDistance;
    }
    
    func setRadiusValue()
    {
        var radiusIndex = self.searchBar.selectedScopeButtonIndex
        var buttons = self.searchBar.scopeButtonTitles as [String]
        println(buttons)
        if(buttons[radiusIndex] == "25 miles")
        {
            println("it's 25")
            searchRadius = 25.0
        }
        else if(buttons[radiusIndex] == "10 miles")
        {
            println("it's 10")
            searchRadius = 10.0
        }
        else if(buttons[radiusIndex] == "5 miles")
        {
            println("it's 5")
            searchRadius = 5.0
        }
        else
        {
            searchRadius = 5.0
        }
        var region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, MilesToMeters(searchRadius), MilesToMeters(searchRadius))
        self.mapView.setRegion(region, animated: true)
    }
    
    func attemptFBPost(restaurant: Restaurant)
    {
        var content = FBSDKShareLinkContent()
        content.contentTitle = "Is getting charitable at "+restaurant.restaurantName!
        content.contentURL = NSURL(string: "https://www.tabletop.com")
        content.contentDescription = "Introducing TableTop, an all new way to give charitably, while you do what you alread love doing - Eating at Restaurants"
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
        
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
    func updateUserLocation() {
        cllManager.startUpdatingLocation()
        mapView.showsUserLocation = true;
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RestaurantTable" {
            NSLog("TABLE TIME")
            var restTableVC = RestaurantTableController()
            restTableVC = segue.destinationViewController as RestaurantTableController
            restTableVC.tableData = self.mergedRestaurauntsList
            NSLog("\(mergedRestaurauntsList)")
            restTableVC.delegate = self
        }
        
        if segue.identifier == "FavoritesTable" {
            //            var favTable =
        }
    }
    
    func addToUserFavorites(restaurant:Restaurant) {
        if let currUser = PFUser.currentUser() {
            if !(restaurant.uniqueId == nil) {
                var resArray:[String] = currUser.valueForKey("Favorites") as [String]
                resArray.append(restaurant.uniqueId!)
                currUser.setValue(resArray, forKey: "Favorites")
                currUser.save()
            }
        }
    }
}

