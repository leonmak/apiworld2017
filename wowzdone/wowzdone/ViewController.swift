//
//  ViewController.swift
//  wowzdone
//
//  Created by Leon Mak on 23/9/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import DocuSignSDK

class ViewController: UIViewController, CLLocationManagerDelegate {

    var mapView = MKMapView()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMap()
        requestLocation()
        
        // login()
        // showSendSignatureRequest()
    }
    
    func login() {
        let username = "1cc0d5ef-e1b2-40bd-91fe-5380a53de8d4";
        let password = "password";
        let integratorKey = "ed4b15ef-88b7-4bc8-9c30-f0f657a9791f";
        let hostUrl: URL! = URL(string: "https://demo.docusign.net/restapi");
        
        DSMManager.login(withUserId: username, password: password, integratorKey: integratorKey, host: hostUrl, completionBlock: { (err: Error?) in
            
            if (err != nil)
            {
                print(String(describing: err));
                // display error prompt
                
            }
            else
            {
                print("User authenticated");
            }
        })
    }
    
    // Must be after user authenticated
    func showSendSignatureRequest() {
        let templateId: String = "4bbf5eeb-d05f-4059-9327-33ba3b5ca5ee"
        DSMTemplatesManager.init().presentSendTemplateControllerWithTemplate(
            withId: templateId,
            signingMode: DSMSigningMode.online,
            presenting: self,
            animated: true,
            completion: { vc, err in
                if err != nil {
                    print(err)
                }
                
                print("done")
            }
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // SETUP MAP
    func setupMap() {
        self.mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.mapView.showsUserLocation = true
        self.view.addSubview(mapView)
    }
    
    func requestLocation() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude
        let lat = userLocation.coordinate.latitude
        updateUserLocation(lat: lat, long: long)
    }
    
    func updateUserLocation(lat: Double, long: Double) {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        print(coord)
        UIView.animate(withDuration: 0.5, delay: 0.3,
                       options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.mapView.setCenter(coord, animated: true)
        }, completion: { _ in
            self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0006, longitudeDelta: 0.0006)
        })
    }
    // END SETUP MAP
    
    // MARK: - touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        locationManager.stopUpdatingLocation()
    }
}

