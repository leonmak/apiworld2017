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
}
