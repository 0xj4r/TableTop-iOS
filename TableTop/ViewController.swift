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



class ViewController: UIViewController, SideBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navBar: UINavigationItem!
   // @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!

    var sideBar:SideBar = SideBar()
    var cllManager = CLLocationManager()
    var locDelegate:CLLocationManagerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForCurrentUser()
        
        var locAuthCheck = CLLocationManager.locationServicesEnabled() // Checks to see if the app has permission for user's location.
        
        cllManager.desiredAccuracy = kCLLocationAccuracyBest
        cllManager.distanceFilter = 100.0 // 100 meters between updates.
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
        var searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = self.searchBar.text
        var requestToQueryParse = self.searchBar.text
        searchRequest.region = MKCoordinateRegionMake(self.mapView.userLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01))
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
            var pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "CustomPinAnnotationView")
            pinView.canShowCallout = true
            var annotationIcon = UIImage(named: "tabletopmapicon.png")
            pinView.image = annotationIcon
            pinView.calloutOffset = CGPointMake(0, 0)
            pinView.tintColor = UIColor.lightGrayColor()
            var favoritesImage = UIImage(named: "uncheckedStar.png")
            var frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            var buttonView = UIView(frame: frame)
            let favButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
            favButton.frame = frame
            favButton.setImage(favoritesImage, forState: .Normal)
            favButton.addTarget(self, action: "favButton_Pressed", forControlEvents: UIControlEvents.TouchUpInside)
            buttonView.addSubview(favButton)
            pinView.leftCalloutAccessoryView = buttonView
            return pinView
        }
        return  nil
    }
    
    @IBAction func favButton_Pressed(sender:AnyObject!) {
        NSLog("That's my Fav");
    }
    
    // Add items to map when searched.
    func searchResultsHandler(response: MKLocalSearchResponse!, error: NSError!) -> Void {
        if let gotError = error { }
        else {
            self.mapView.removeAnnotations(self.mapView.annotations!)
            var placemarks:[CLPlacemark] = []
            var items: [MKMapItem] = response.mapItems as [MKMapItem]
            var intCount = 0
            for each in items {
                var id = "id \(intCount)"
                //placemarks.append(each.placemark)
                var myAnnotation = MKPointAnnotation()
                myAnnotation.setCoordinate(each.placemark.coordinate)
                myAnnotation.title = each.placemark.name
                var annoView = MKPinAnnotationView(annotation: myAnnotation, reuseIdentifier: id)
                self.mapView.viewForAnnotation(myAnnotation)
                self.mapView.addAnnotation(myAnnotation)
//                buildAndSendParseQueryForLocations(each)
                intCount++
            }
        }
    }
    
    func buildAndSendParseQueryForLocations(mapItem: MKMapItem) -> Void {
        var query = PFQuery(className: "Restaurant")
        var geoPointCoordinate = PFGeoPoint(latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.longitude)
        query.whereKey("latLong", nearGeoPoint: geoPointCoordinate, withinMiles: 15.0)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects.count) map items.")
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        println(object.objectId)
                        var myAnnotation = MKPointAnnotation()
                        myAnnotation.title = object.valueForKey("restaurantName") as String!
                        var geoPoint = object.objectForKey("latLong") as PFGeoPoint!
                        var annotationLoc = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                        myAnnotation.setCoordinate(annotationLoc)
                        var annoView = MKPinAnnotationView(annotation: myAnnotation, reuseIdentifier: object.objectId)
                        var right:UIButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
                        annoView.rightCalloutAccessoryView = right
                        self.mapView.viewForAnnotation(myAnnotation)
                        self.mapView.addAnnotation(myAnnotation)
                    }
                }
                //Magic stuff happens here
            } else {
                // Log details of the failure
                println("Error: \(error) \(error.userInfo!)")
            }
        }
    }

    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.leftCalloutAccessoryView {
            NSLog("LEFT CALLOUT")
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
}

