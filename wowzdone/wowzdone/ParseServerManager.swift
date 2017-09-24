//
//  ParseServerManager.swift
//  wowzdone
//
//  Created by Leon Mak on 24/9/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import Foundation
import Alamofire

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
}
