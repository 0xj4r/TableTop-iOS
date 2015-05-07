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

class ViewController: UIViewController, SideBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navBar: UINavigationItem!
   // @IBOutlet weak var searchBar: UISearchBar!
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
    override func viewDidLoad() {
        super.viewDidLoad()
        if(PFUser.currentUser() == nil){
            
            
            var logInViewController = TableTopLoginView()
            logInViewController.delegate = self
            
            var signUpViewController = TableTopSignUpViewController ()
            signUpViewController.delegate = self
            logInViewController.signUpController=signUpViewController
            
            logInViewController.fields = PFLogInFields.Default | PFLogInFields.Twitter | PFLogInFields.Facebook | PFLogInFields.DismissButton | PFLogInFields.SignUpButton
           
            self.presentViewController(logInViewController, animated: true , completion: nil)
            
        }
        searchRadius = 5.0
        
        var locAuthCheck = CLLocationManager.locationServicesEnabled() // Checks to see if the app has permission for user's location.
        
        
        cllManager.desiredAccuracy = kCLLocationAccuracyBest
        cllManager.distanceFilter = 10.0 // 100 meters between updates.
        cllManager.requestWhenInUseAuthorization()
        cllManager.startUpdatingLocation()
        
        
        var latDelta:CLLocationDegrees = 0.01
        var longDelta:CLLocationDegrees = 0.01
        
        var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)

        
        var tab =  self.tabBarController?.tabBar
        tab?.tintColor = UIColor.whiteColor()
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true

        
        sideBar = SideBar(sourceView: self.view, menuItems:["Josh Ransom", "Balance: 45.00", "Account", "Charities", "Events"])
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
    
        
        
        
        
    
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func sideBarDidSelectButtonAtIndex(index: Int) {
        if index == 0 {
        } else if index == 1{
                  }
    }
    
    
    
    @IBAction func searchBarButtonClicked(sender: UIBarButtonItem) {
        if self.searchBar.hidden {
            self.searchBar.hidden = false
            
            NSLog("Not Hidden")
        } else {
            self.searchBar.hidden = true
            searchBar.resignFirstResponder()
            NSLog("Hidden")
        }
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        self.mapView.setRegion(MKCoordinateRegionMake(self.mapView.userLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01)), animated: true)
    }
        // Not used.
    
    @IBAction func openMenu(sender: UIBarButtonItem) {
        if sideBar.isSideBarOpen{
            sideBar.showSideBar(false)
        }
        else {
            sideBar.showSideBar(true) }
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        setRadiusValue()
        var searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = self.searchBar.text
        var requestToQueryParse = self.searchBar.text
        //searchRequest.region = MKCoordinateRegionMake(self.mapView.userLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01))
        searchRequest.region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, MilesToMeters(searchRadius), MilesToMeters(searchRadius))
        var localSearch = MKLocalSearch(request: searchRequest)
        var searchResponse = MKLocalSearchResponse()
        var mapError = NSError()
        localSearch.startWithCompletionHandler(searchResultsHandler)
    }
    
    @IBAction func viewTapped(sender: AnyObject) {
        searchBar.resignFirstResponder()
    }
    
    // Add items to list when searched.
    
    func searchResultsHandler(response: MKLocalSearchResponse!, error: NSError!) -> Void {
        buildAndSendParseQueryForLocations()
        if let gotError = error {
            println("Error in Search")
        }
        else
        {
        self.mapView.removeAnnotations(self.mapView.annotations!)
        
        //println("COUNT : \(response.mapItems.count)")
            var placemarks:[CLPlacemark] = []
            var items: [MKMapItem] = response.mapItems as [MKMapItem]
            var intCount = 0
            for each in items {
                var id = "id \(intCount)"
                var restaurant = Restaurant(name: each.name!, coordinate: each.placemark.coordinate)
                mapKitRestaurauntResponse.append(restaurant)
                println(each)
                intCount++
            }
            
        }
    }
    
    //ask parse for items near user
    func buildAndSendParseQueryForLocations() -> Void {
        parseRestaurantResponses = []
        var query = PFQuery(className: "Restaurant")
        var location = self.mapView.userLocation.coordinate
        var geoPointCoordinate = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        println(geoPointCoordinate)
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
                        var restaurant = Restaurant(name: object.valueForKey("restaurantName") as String!, coordinate: coordinateForRestaurant, id: object.objectId)
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
    
    //combine found lists of items
    func mergeListsToFindCommonResults()
    {
        mergedRestaurauntsList = []
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
            var myAnnotation = MKPointAnnotation()
            myAnnotation.title = restaurant.restaurantName
            myAnnotation.coordinate = restaurant.restaurantCoordinate!
            var annoView = MKPinAnnotationView(annotation: myAnnotation, reuseIdentifier: restaurant.uniqueId!)
            self.mapView.viewForAnnotation(myAnnotation)
            self.mapView.addAnnotation(myAnnotation)
        }
        
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
    
    func AttemptFBPost(/*postString: String*/)
    {
       //var isEqualTo = (FBSDKAccessToken.currentAccessToken().tokenString == Globals.global.currentToken.tokenString)
        //if(Globals.global.currentToken.tokenString == "")
        //{
         //   println("not Signed in to facebook")
        //}
        //if(isEqualTo)
        //{
            var content = FBSDKShareLinkContent()
            content.contentTitle = "Charitable Giving, Food Discounts."
            content.contentURL = NSURL(string: "https://www.tabletop.com")
            content.contentDescription = "Introducing TableTop, an all new way to give charitably, while you do what you alread love doing - Eating at Restaurants"
            FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: nil)
        //}
    }
    
}

