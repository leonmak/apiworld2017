//
//  Extensions.swift
//  wowzdone
//
//  Created by Leon Mak on 23/9/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import MapKit

extension CLLocationCoordinate2D {
    func near(other: CLLocationCoordinate2D, buffer: Double = 0.0001) -> Bool {
        let latDiff = self.latitude - other.latitude
        let lngDiff = self.longitude - other.longitude
        return latDiff < buffer && lngDiff < buffer
    }
    
    func midPoint(location:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let lng1 = longitude * Double.pi / 180
        let lng2 = location.longitude * Double.pi / 180
        let lat1 = latitude * Double.pi / 180
        let lat2 = location.latitude * Double.pi / 180
        let dLon = lng2 - lng1
        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)
        let lat3 = atan2(sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y))
        let lon3 = lng1 + atan2(y, cos(lat1) + x)
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat3 * 180 / Double.pi,
                                                                        lon3 * 180 / Double.pi)
        return center
    }

}

