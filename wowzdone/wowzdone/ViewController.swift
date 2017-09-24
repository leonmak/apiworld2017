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
import ChameleonFramework

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var isDemo = true
    var mapView = MKMapView()
    var userAnnotation: MKPointAnnotation?
    var locationManager = DemoLocationManager()
    
    var startButton: ColoredButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMap()
        requestLocation()
        setupStartJob()
    }

    // MARK: - SETUP
    // MARK: Map
    func setupMap() {
        self.mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.mapView.showsUserLocation = !isDemo
        self.view.addSubview(mapView)
    }
    
    func requestLocation() {
        locationManager.delegate = self
        if isDemo {
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

    // MARK: - UPDATE
    // MARK: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        let long = userLocation.coordinate.longitude
        let lat = userLocation.coordinate.latitude
        updateUserLocation(lat: lat, long: long)
    }
    
    func updateUserLocation(lat: Double, long: Double) {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        print("UPDATE LOC: ", coord)
        
        if isDemo && locationManager.count == 0 {
            locationManager.stopUpdatingTimer() // initialize map
        }

        DispatchQueue.main.async {
            if self.userAnnotation == nil {
                self.userAnnotation = MKPointAnnotation()
                self.userAnnotation!.coordinate = coord
                self.userAnnotation!.subtitle = "User Location"
                self.mapView.addAnnotation(self.userAnnotation!)
            }

            // Update map user coordinates and map
            UIView.animate(withDuration: 0.15, delay: 0, options: .allowUserInteraction, animations: {
                self.userAnnotation!.coordinate = coord
            }, completion: { _ in })
            
            UIView.animate(withDuration: 0.3, delay: 0.3, options: .allowUserInteraction, animations: {
                self.mapView.setCenter(coord, animated: false)
            }, completion: { _ in
                self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0006, longitudeDelta: 0.0006)
            })
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // MARK: - touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
    }
    
    // MARK: start jpb
    func setupStartJob() {
        let width = view.frame.width * 0.8
        let height = CGFloat(45.0)
        let x = view.frame.width * 0.1
        let y = view.frame.height * 0.8
        let frame = CGRect(x: x, y: y, width: width, height: height)
        self.startButton = ColoredButton(frame: frame, color: UIColor.flatBlack)
        self.startButton.frame = frame
        self.startButton.setTitle("Start Job", for: .normal)
        self.startButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)

        self.view.addSubview(self.startButton)
    }
    
    func buttonClicked(_ sender: AnyObject?) {
        
        if sender === self.startButton {
            print("STARTED JOB")
            locationManager.startUpdatingLocation()
            // create job
            // assign to user
        }
    }
}

