//
//  OwnerVC.swift
//  wowzdone
//
//  Created by Leon Mak on 24/9/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import UIKit
import HyperTrack
import MapKit
import Parse
import ParseLiveQuery


// HTTPS BUG ios11:
// https://github.com/AFNetworking/AFNetworking/issues/3999
//let liveQueryClient = ParseLiveQuery.Client(server: "wss://apiworld2017.back4app.io")
//var subscription: Subscription<PFObject>!
import Alamofire

class OwnerVC: UIViewController, CLLocationManagerDelegate {

    var locationManager = DemoLocationManager(isOwner: true)
    var htContractor: HyperTrackUser?
    var mapView = MKMapView()
    var isDemo = true
    var ownerAnnotation: MKPointAnnotation?
    var userAnnotation: MKPointAnnotation?   // Contractor
    
    var updateLocationTimer: Timer?
    var jobDoneTimer: Timer?
    let username = "1cc0d5ef-e1b2-40bd-91fe-5380a53de8d4";
    let password = "password";
    let integratorKey = "ed4b15ef-88b7-4bc8-9c30-f0f657a9791f";
    let hostUrl = "https://demo.docusign.net/restapi";
    let templateId = "4bbf5eeb-d05f-4059-9327-33ba3b5ca5ee"
    let accountNo = "3724702"
    var lastEnvelopeId = ""

    @IBOutlet weak var sendNowBtn: UIButton!
    @IBOutlet weak var scheduleOTPBtn: UIButton!
    @IBOutlet weak var profileImg: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMap()
        requestLocation()
        
        getContractor()
        self.updateLocationTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.updateContractorLocation),
            userInfo: nil,
            repeats: true
        )
        self.jobDoneTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.checkJobDone),
            userInfo: nil,
            repeats: true
        )
        // setupLiveQueries()
        // HTTPS BUG ios11:
        // https://github.com/AFNetworking/AFNetworking/issues/3999
        profileImg.layer.zPosition = 100
        sendNowBtn.layer.zPosition = 100
        scheduleOTPBtn.layer.zPosition = 100
    }
    
    func checkJobDone() {
        print("Checking")
    }
    
    func updateContractorLocation() {
        var query = PFQuery(className: Constants.parseLocationMessageClass)
        query.whereKeyExists("location")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                if let object = objects!.first
                , let point = object["location"] as? PFGeoPoint {
                    self.updateOwnerLocation(lat: point.latitude, long: point.longitude)
                }
            } else {
                print("Error: \(error!)")
            }
        }
        
        query = PFQuery(className: "JobDone")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                print("Successfully retrieved \(objects!.count) scores.")
                if let object = objects!.first, let isDone = object["isDone"] as? Bool {
                    if isDone {
                        self.alert(message: "Your job is done.", title: "Sign to approve the job.")
                    }
                }
            } else {
                print("Error: \(error!)")
            }
        }


    }
    
    
    func getContractor() {
        HyperTrack.getOrCreateUser("Mr. Bob", _phone: Constants.phone, Constants.phone) { (user, error) in
            if (error != nil) {
                NSLog(error.debugDescription)
                return
            }
            if (user != nil) {
                self.htContractor = user
            }
        }
    }
    
    // MARK: Setup Map & location
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        let long = userLocation.coordinate.longitude
        let lat = userLocation.coordinate.latitude
        updateOwnerLocation(lat: lat, long: long)
    }
    
    func updateUserLocation(lat: Double, long: Double) {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        print("UPDATE CONTRACTOR LOC: ", coord)
        
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

        }
    }
    
    func updateOwnerLocation(lat: Double, long: Double) {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
        print("UPDATE LOC: ", coord)
        
        
        DispatchQueue.main.async {
            if self.ownerAnnotation == nil {
                self.ownerAnnotation = MKPointAnnotation()
                self.ownerAnnotation!.coordinate = coord
                self.ownerAnnotation!.subtitle = "User Location"
                self.mapView.addAnnotation(self.ownerAnnotation!)
                if self.isDemo {
                    self.placeDestinationPin()
                    return
                }
            }
            
            // Update map user coordinates and map
            UIView.animate(withDuration: 0.15, delay: 0, options: .allowUserInteraction, animations: {
                self.ownerAnnotation!.coordinate = coord
                self.mapView.setCenter(coord, animated: true)
                self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0006, longitudeDelta: 0.0006)
            }, completion: { _ in })
            
            self.locationManager.stopUpdatingTimer()
        }
    }
    
    func placeDestinationPin() {
        if ownerAnnotation == nil {
            return
        }
        let destination = Constants.ownerDestination
        let center = destination.coordinate.midPoint(location: ownerAnnotation!.coordinate)
        let region = MKCoordinateRegionMake(center, MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
        self.mapView.setRegion(region, animated: true)
        
        let pointAnnotation = ImageAnnotation(location: destination.coordinate)
        pointAnnotation.imageName = "user_pin"
        pointAnnotation.title = "Your Job"
        let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "destination_pin")
        self.mapView.addAnnotation(pinAnnotationView.annotation!)
    }

    // MARK: - LiveQueries
    func setupLiveQueries() {
//        let msgQuery = PFQuery(className: Constants.parseLocationMessageClass).whereKeyExists("objectId")
//        subscription = liveQueryClient.subscribe(msgQuery).handle(Event.entered) { _, object in
//            self.handleMessage(object)
//            print("message: ", object)
//        }
        
             self.showSignScreen()
        
    }
    
    func showSignScreen() {
        sendEnvelope(callback: {
            (envelopeId) in ()
            self.lastEnvelopeId = envelopeId
            print("ENVELOPE ID: " + envelopeId)
            
            self.getRedirectUrl(envelopeId: self.lastEnvelopeId, callback: {
                (url) in ()
                print("REDIRECT URL: " + url)
                UIApplication.shared.open(NSURL(string:"https://demo.docusign.net/Member/EmailStart.aspx?a=e7f5f4ab-ba8f-44b9-aeba-feb21ea2ac7a&acct=c5078423-539c-41ef-82cf-9359419fb6ac&er=3306a55f-840e-45a9-b10b-771913adaede&espei=bc3fc6f8-a879-4b04-8037-3bb471a702d8")! as URL, options: [:], completionHandler: nil)
            })
        })
    }

    func handleMessage(_ object: PFObject) {
        guard let point = object["location"] as? PFGeoPoint else {
            NSLog("NO GEO-POINTS FOUND")
            return
        }
        updateUserLocation(lat: point.latitude, long: point.longitude)
    }
    
    func alert(message: String, title: String) -> Void {
        let alert = UIAlertController(title: title as String, message: message as String, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Leave your E-signature", style: UIAlertActionStyle.default, handler: {_ in
            self.showSignScreen()
            ParseServerManager.instance.jobDone(isDone: false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getRedirectUrl(envelopeId: String, callback: @escaping (_ url: String) -> ()) {
        let url = hostUrl + "/v2/accounts/" + accountNo + "/envelopes/" + envelopeId + "/views/recipient"
        
        Alamofire.request(url,
                          method: .post,
                          parameters: [
                            "authenticationMethod": "email",
                            "userName": "Contractor",
                            "email": "oqyxxy93@gmail.com",
                            "returnUrl": "http://google.com"
            ],
                          encoding: JSONEncoding.default,
                          headers: [
                            "X-DocuSign-Authentication":
                                "{ \"Username\": \"" + username + "\", \"Password\":\"" + password + "\", \"IntegratorKey\":\"" + integratorKey + "\" }"
            ]
            ).responseJSON {
                response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result
                
                if let json = response.result.value as? [String: Any] {
                    print("JSON: \(json)") // serialized json response
                    
                    if let url = json["url"] as? String {
                        callback(url)
                    }
                }
                
        }
    }
    
    func sendEnvelope(callback: @escaping (String) -> ()) {
        let url = hostUrl + "/v2/accounts/" + accountNo + "/envelopes"
        
        Alamofire.request(url,
                          method: .post,
                          parameters: [
                            "templateId": templateId,
                            "status": "sent",
                            "recipients": [
                                "templateRoles": [
                                    [
                                        "email": "oqyxxy93@gmail.com",
                                        "name": "Contractor",
                                        "clientUserId": "1",
                                        "embeddedRecipientStartURL": "SIGN_AT_DOCUSIGN"
                                    ]
                                ]
                            ]
            ],
                          encoding: JSONEncoding.default,
                          headers: [
                            "X-DocuSign-Authentication":
                                "{ \"Username\": \"" + username + "\", \"Password\":\"" + password + "\", \"IntegratorKey\":\"" + integratorKey + "\" }"
            ]
            ).responseJSON {
                response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result
                
                if let json = response.result.value as? [String: Any] {
                    print("JSON: \(json)") // serialized json response
                    
                    if let envelopeId = json["envelopeId"] as? String {
                        callback(envelopeId)
                    }
                }
                
        }
    }

    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    

}
