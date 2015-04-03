//
//  Restaurant.swift
//  TableTop
//
//  Created by Tim Ferguson on 4/2/15.
//  Copyright (c) 2015 Josh Ransom. All rights reserved.
//

import Foundation
import MapKit


class Restaurant : Equatable{
    var restaurantName = String?()
    var restaurantCoordinate = CLLocationCoordinate2D?()
    var uniqueId = String?()
    
    init(name:  String, coordinate: CLLocationCoordinate2D?, id : String)
    {
        restaurantName = name
        restaurantCoordinate = coordinate
        uniqueId = id
    }
    init(name:  String, coordinate: CLLocationCoordinate2D?)
    {
        restaurantName = name
        restaurantCoordinate = coordinate
    }


}
func ==(lhs: Restaurant, rhs: Restaurant) -> Bool {
    return lhs.restaurantName == rhs.restaurantName
}

