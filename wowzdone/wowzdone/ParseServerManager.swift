//
//  ParseServerManager.swift
//  wowzdone
//
//  Created by Leon Mak on 24/9/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import Foundation
import Alamofire
import ParseLiveQuery
import Parse


/// A singleton manager for retrieving OTP from Back4App parse server.
class ParseServerManager {
    private init() {}    
    static let instance = ParseServerManager()
    
    /// Accepts a callback and returns a One Time password.
    /// E.g. call:
    //        getOTP(callback: {
    //            (otp: String) -> () in
    //            print(otp)
    //        })
    func getOTP(callback: @escaping (String) -> ()) {
        NSLog("Retrieving OTP..")
        Alamofire.request("http://apiworld2017.back4app.io/reached", method: .post).responseJSON {
            response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value as? [String: Any] {
                print("JSON: \(json)") // serialized json response
                if json["error"] != nil {
                    print("returning default OTP")
                    callback("2229")
                }
                print("OTP retreived successfully.")
                if let otp = json["otp"] as? String {
                    callback(otp)
                }
            }
        }
    }
    
    func upsertMessage(coord: CLLocationCoordinate2D, userId: String) {
        let point = PFGeoPoint(latitude: coord.latitude, longitude: coord.longitude)
        let query = PFQuery(className: Constants.parseLocationMessageClass)
        query.whereKey("userId", equalTo: userId)
        print("UPSERSTING")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                print("Successfully retrieved \(objects!.count) scores.")
                if objects!.count == 0 {
                    let message: PFObject = PFObject(className: Constants.parseLocationMessageClass)
                    message["location"] = point
                    message["userId"] = userId
                    message.saveInBackground { (_, er) in
                        if !(er != nil) {
                            print("Message uploaded to back4app")
                        } else {
                            print(er as Any)
                        }
                    }
                } else {
                    // if existing
                    if let object = objects!.first,
                        let onlineUserId = object["userId"] as? String,
                        onlineUserId == userId {
                        object.setValue(point, forKey: "location")
                        object.saveInBackground { (_, er) in
                            if !(er != nil) {
                                print("Message uploaded to back4app")
                            } else {
                                print(er as Any)
                            }
                        }
                    }
                    
                }
            } else {
                print("ERROR: ", error.debugDescription)
                // if none create
            }
        }
    }
    
    func jobDone(isDone: Bool) {
        let query = PFQuery(className: "JobDone")
        query.whereKeyExists("isDone")
        print("done job")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                print("Successfully retrieved \(objects!.count) scores.")
                if objects!.count == 0 {
                    let message: PFObject = PFObject(className: "JobDone")
                    message["isDone"] = isDone
                    message.saveInBackground { (_, er) in
                        if !(er != nil) {
                            print("Job uploaded to back4app")
                        } else {
                            print(er as Any)
                        }
                    }
                } else {
                    // if existing
                    if let object = objects!.first 
                    {
                        object.setValue(isDone, forKey: "isDone")
                        object.saveInBackground { (_, er) in
                            if !(er != nil) {
                                print("Job uploaded to back4app")
                            } else {
                                print(er as Any)
                            }
                        }
                    }
                    
                }
            } else {
                print("ERROR: ", error.debugDescription)
                // if none create
            }
        }
    }
}
