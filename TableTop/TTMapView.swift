//
//  TTMapView.swift
//  TableTop
//
//  Created by Josh Ransom on 4/2/15.
//  Copyright (c) 2015 Josh Ransom. All rights reserved.
//

import UIKit
import MapKit


class TTMapView: MKMapView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func viewForAnnotation(annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKUserLocation{
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = self.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            
        if(pinView == nil){
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinColor = .Red
            
            var calloutButton = UIButton.buttonWithType(.DetailDisclosure) as UIButton
            pinView!.rightCalloutAccessoryView = calloutButton
            
            //        var starButton = UIButton()
            //        starButton.setAttributedTitle(NSAttributedString(string: "Button"), forState: UIControlState.Normal)
            //        pinView!.leftCalloutAccessoryView = starButton
        } else {
            pinView!.annotation = annotation
        }
        return pinView!
    }
    

}
