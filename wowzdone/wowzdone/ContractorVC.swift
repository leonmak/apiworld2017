//
//  ContractorVC.swift
//  wowzdone
//
//  Created by Leon Mak on 23/9/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import UIKit
import MapKit

import HyperTrack
import CoreLocation
import ChameleonFramework

class ContractorVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var isDemo = true
    var mapView = MKMapView()
    var userAnnotation: MKPointAnnotation?
    var locationManager = DemoLocationManager()
    
    var role = Role.contractor
    var htUser: HyperTrackUser?
    var htActionId: String?
    
    var startButton: ColoredButton!
    var timeLeftOTP = 0
    var OTP = ""
    var countDownTimer: Timer?
    
    var renewOTPBtn: ColoredButton?
    var jobDoneBtn: ColoredButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        requestLocation()
        
        setupStartJob()
        setupHyperTrack()

    }

    // MARK: - SETUP
    // MARK: Map
    func setupMap() {
        self.mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.mapView.showsUserLocation = !isDemo
        self.view.addSubview(mapView)
    }
    
    func setupHyperTrack() {
        HyperTrack.requestAlwaysAuthorization()
        HyperTrack.requestMotionAuthorization()
        HyperTrack.getOrCreateUser("Mr. Bob", _phone: Constants.phone, Constants.phone) { (user, error) in
            if (error != nil) {
                NSLog(error.debugDescription)
                return
            }
            if (user != nil) {
                self.htUser = user
            }
        }

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
                if self.isDemo {
                    self.placeDestinationPin()
                    return
                }
            }

            // Update map user coordinates and map
            UIView.animate(withDuration: 0.15, delay: 0, options: .allowUserInteraction, animations: {
                self.userAnnotation!.coordinate = coord
            }, completion: { _ in })
            
            UIView.animate(withDuration: 0.3, delay: 0.3, options: .allowUserInteraction, animations: {
                self.mapView.setCenter(coord, animated: true)
            }, completion: { _ in
                self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0006, longitudeDelta: 0.0006)
            })
            
            if self.userAnnotation!.coordinate.near(other: Constants.ownerDestination.coordinate) {
                self.startRequestingOTP()
            }
        }
    }
    
    // MARK: - OTP
    func startRequestingOTP() {
        self.setStartBtnToRequesingtOTP()
        ParseServerManager.instance.getOTP(callback: {otp in
            self.displayOTPAlert(otp)
        })
    }
    
    func displayOTPAlert(_ otp: String) {
        // Timer countdown
        let alert = UIAlertController(title: "One-time pass: \(otp)", message: "This one time password expires in 1 min", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Done", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
            self.OTP = otp
            self.timeLeftOTP = 60
            self.setStartBtnToReceivedOTP()
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func setStartBtnToReceivedOTP() {
        UIView.animate(withDuration: 1.5, animations: {
            self.startButton.backgroundColor = UIColor.flatGreen
        })
        startCountdownTimer()
        displayRenewOTPBtn()
        displayJobDoneBtn()
    }
    
    func displayRenewOTPBtn() {
        if self.renewOTPBtn != nil {
            return
        }
        let width = view.frame.width * 0.35
        let height = CGFloat(45.0)
        let x = view.frame.width * 0.1
        let y = view.frame.height * 0.85 - CGFloat(60)
        let frame = CGRect(x: x, y: y, width: width, height: height)
        self.renewOTPBtn = ColoredButton(frame: frame,
                                         color: UIColor.flatOrange,
                                         borderColor: UIColor.clear)
        self.renewOTPBtn!.frame = frame
        self.renewOTPBtn!.setTitle("Renew OTP", for: .normal)
        self.renewOTPBtn!.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        self.view.addSubview(self.renewOTPBtn!)
    }
    
    func displayJobDoneBtn() {
        if self.jobDoneBtn != nil {
            return
        }
        let width = view.frame.width * 0.35
        let height = CGFloat(45)
        let x = view.frame.width * 0.55
        let y = view.frame.height * 0.85 - CGFloat(60)
        let frame = CGRect(x: x, y: y, width: width, height: height)
        self.jobDoneBtn = ColoredButton(frame: frame,
                                         color: UIColor.flatBlack,
                                         borderColor: UIColor.clear)
        self.jobDoneBtn!.frame = frame
        self.jobDoneBtn!.setTitle("Job Done", for: .normal)
        self.jobDoneBtn!.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)
        self.view.addSubview(self.jobDoneBtn!)
    }
    
    func startCountdownTimer() {
        if self.countDownTimer != nil {
            self.countDownTimer?.invalidate()
            self.countDownTimer = nil
        }
        self.countDownTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.countdownOTP),
            userInfo: nil,
            repeats: true
        )
    }
    
    func countdownOTP() {
        self.timeLeftOTP -= 1
        print("Counting down: \(self.timeLeftOTP)")
        self.startButton.setTitle("OTP: \(self.OTP) (\(self.timeLeftOTP) sec)", for: .normal)
        if self.timeLeftOTP == 0 {
            self.countDownTimer?.invalidate()
        }
    }

    
    func setStartBtnToRequesingtOTP() {
        UIView.animate(withDuration: 0.5, animations: {
            self.startButton.backgroundColor = UIColor.flatOrange
            self.startButton.layer.borderColor = UIColor.clear.cgColor
            self.startButton.setTitle("Requesting OTP", for: .normal)
        })
    }
    
    // MARK: - Image Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "destination_pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! ImageAnnotation
        annotationView?.image = UIImage(named: customPointAnnotation.imageName!)
        return annotationView
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // MARK: - touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    // MARK: start job
    func setupStartJob() {
        setupStartJobBtn()
    }
    
    func placeDestinationPin() {
        if userAnnotation == nil {
            return
        }
        let destination = Constants.ownerDestination
        let center = destination.coordinate.midPoint(location: userAnnotation!.coordinate)
        let region = MKCoordinateRegionMake(center, MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
        self.mapView.setRegion(region, animated: true)
        
        let pointAnnotation = ImageAnnotation(location: destination.coordinate)
        pointAnnotation.imageName = "user_pin"
        pointAnnotation.title = "Job Location"
        let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "destination_pin")
        self.mapView.addAnnotation(pinAnnotationView.annotation!)
    }
    
    func setupStartJobBtn() {
        let width = view.frame.width * 0.8
        let height = CGFloat(45.0)
        let x = view.frame.width * 0.1
        let y = view.frame.height * 0.85
        let frame = CGRect(x: x, y: y, width: width, height: height)
        self.startButton = ColoredButton(frame: frame,
                                         color: UIColor.flatBlack,
                                         borderColor: UIColor.flatBlackDark)
        self.startButton.frame = frame
        self.startButton.setTitle("Accept Job Request", for: .normal)
        self.startButton.addTarget(self, action: #selector(self.buttonClicked(_:)), for: .touchUpInside)

        self.view.addSubview(self.startButton)
    }
    
    func buttonClicked(_ sender: AnyObject?) {
        if sender === self.startButton {
            print("STARTED JOB")
            locationManager.startUpdatingLocation()
            if self.isDemo {
                HyperTrack.startMockTracking()
            } else {
                HyperTrack.startTracking()
            }
            upsertAction()
        } else if sender === self.jobDoneBtn {
            self.completeAction()
        } else if sender === self.renewOTPBtn {
            self.startRequestingOTP()
        }
    }
    
    // MARK: - HT ACTION
    func upsertAction() {
        let expectedPlace = HyperTrackPlace().setLocation(coordinates: Constants.ownerDestination.coordinate)
        let htActionParams = HyperTrackActionParams()
        htActionParams.expectedPlace = expectedPlace
        htActionParams.type = "task"
        htActionParams.lookupId = Constants.uuidstring
        htActionParams.userId = self.htUser?.id
        HyperTrack.createAndAssignAction(htActionParams) { action, error in
            if let error = error {
                NSLog(error.debugDescription)
                return
            }
            if let action = action {
                self.htActionId = action.id
            }
        }
    }
    
    func completeAction() {
        guard let actionId = self.htActionId else {
            NSLog("No Action ID created and assigned!")
            return
        }
        HyperTrack.completeAction(self.htActionId!)
        print("Completed Action id: \(actionId)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if isDemo {
            HyperTrack.stopMockTracking()
        } else {
            HyperTrack.stopTracking()
        }
    }
}

