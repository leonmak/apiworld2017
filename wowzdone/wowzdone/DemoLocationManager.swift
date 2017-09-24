//
//  DemoLocationManager.swift
//  wowzdone
//
//  Created by Leon Mak on 23/9/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import MapKit

class DemoLocationManager: CLLocationManager {
    var updateLocationTimer: Timer?
    var count = 0
    var isOwner = false

    convenience init(isOwner: Bool=false) {
        self.init()
        self.isOwner = isOwner
    }
    
    override func requestWhenInUseAuthorization() {
    }
    
    override func startUpdatingLocation() {
        self.updateLocationTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(DemoLocationManager.updateUserLocation),
            userInfo: nil,
            repeats: true
        )
    }

    func updateUserLocation() {
        if self.isOwner {
            self.delegate?.locationManager!(self, didUpdateLocations: [Constants.ownerDestination])
            
            return
        }
        
        if count == Constants.contractorPath.count {
            updateLocationTimer?.invalidate()
            return
        }
        self.delegate?.locationManager!(self, didUpdateLocations: [Constants.contractorPath[count]])
        count += 1
    }
    
    func stopUpdatingTimer() {
        updateLocationTimer?.invalidate()
    }
        
    // TODO: Override all other methods used.
    
}
