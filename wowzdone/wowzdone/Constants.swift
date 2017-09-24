//
//  Constants.swift
//  wowzdone
//
//  Created by Leon Mak on 23/9/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import Foundation
import MapKit

struct Constants {
    static let name = "Leon"
    static let phone = "16282274364"
    static let contractorPath: [CLLocation] = [
        CLLocation(latitude: 37.73406434, longitude: -122.422057),
        CLLocation(latitude: 37.73401343, longitude: -122.422126),
        CLLocation(latitude: 37.73394555, longitude: -122.422218),
        CLLocation(latitude: 37.73389889, longitude: -122.422271),
        CLLocation(latitude: 37.73397525, longitude: -122.422464),
        CLLocation(latitude: 37.73411950, longitude: -122.422539),
        CLLocation(latitude: 37.73425526, longitude: -122.422695),
        CLLocation(latitude: 37.73434859, longitude: -122.422840),
        CLLocation(latitude: 37.73444617, longitude: -122.423001),
        CLLocation(latitude: 37.73450981, longitude: -122.423151),
    ]
    static let initialLocation = contractorPath.first!
    static let ownerDestination = contractorPath.last!
    static let uuidstring = UUID().uuidString
}
