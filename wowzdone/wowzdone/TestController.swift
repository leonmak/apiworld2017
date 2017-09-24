
//
//  TestController.swift
//  wowzdone
//
//  Created by Leon Mak on 23/9/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import DocuSignSDK

class TestController: UIViewController, CLLocationManagerDelegate {
    
    let username = "1cc0d5ef-e1b2-40bd-91fe-5380a53de8d4";
    let password = "password";
    let integratorKey = "ed4b15ef-88b7-4bc8-9c30-f0f657a9791f";
    let hostUrl = "https://demo.docusign.net/restapi";
    let templateId = "4bbf5eeb-d05f-4059-9327-33ba3b5ca5ee"
    let accountNo = "3724702"
    var lastEnvelopeId = ""
    
    @IBAction func onClick(_ sender: Any) {
        sendEnvelope(callback: {
            (envelopeId) in ()
            self.lastEnvelopeId = envelopeId
            print("ENVELOPE ID: " + envelopeId)
        })
    }
    
    @IBAction func onClick2(_ sender: Any) {
        getRedirectUrl(envelopeId: self.lastEnvelopeId, callback: {
            (url) in ()
            print("REDIRECT URL: " + url)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    // Must be after user authenticated
//    func sendEnvelope() {
//
//        DSMTemplatesManager.init().presentSendTemplateControllerWithTemplate(
//            withId: templateId,
//            signingMode: DSMSigningMode.online,
//            presenting: self,
//            animated: true,
//            completion: { vc, err in
//                if err != nil {
//                    print(err)
//                }
//
//                print("done")
//        }
//        )
//    }
}

