//
//  AppDelegate.swift
//  wowzdone
//
//  Created by Leon Mak on 23/9/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import UIKit
import HyperTrack
import Parse
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        HyperTrack.initialize("pk_71bb1d6f08dcd32727f1cea4506eed3eb9942878")
        HyperTrack.registerForNotifications()

        let configuration = ParseClientConfiguration {
            $0.applicationId = "jvzkcJ27j6ZtvJf5TCwhvbptRsdiSDLOrlJMdwaN"
            $0.clientKey = "FPmnSKZx0dMrSBjDm09xBKoRm20QZmEwo71DJw8A⁠⁠⁠⁠"
            $0.server = "https://parseapi.back4app.com"
            $0.isLocalDatastoreEnabled = true // If you need to enable local data store
        }
        Parse.initialize(with: configuration)
        
//        signup(
//            username: "contractor",
//            type: "contractor",
//            email: "contractor@remotely.com",
//            password: "password",
//            callback: { _ in }
//
//        )

//        login("contractor", "password")
//        updateContractorLocation(10.0, 10.0)
//
//        signup(
//            username: "owner",
//            type: "owner1",
//            email: "owner@remotely.com",
//            password: "password",
//            callback: { _ in }
//        )
        return true
    }

    func signup(username: String, type: String, email: String, password: String, callback: @escaping () -> ()) {
        let user = PFUser()
        user.setValue(type, forKey: "type")
        user.username = username
        user.password = password
        user.email = email

        user.signUpInBackground { (succeeded: Bool, error: Error?) in
            if let error = error {
                print(error)
                // let errorString = error.userInfo["error"] as? NSString
                // Show the errorString somewhere and let the user try again.
            } else {
                callback()
            }
        }
    }
//
//    func login(username: String, password: String) {
//        PFUser.logInWithUsername(username, password: password)
//    }
//
//    func signup(username: String, type: String, email: String, password: String, callback: () -> ()) {
//        var user = PFUser()
//        user.username = username
//        user.password = password
//        user.email = email
//
//        user.signUpInBackgroundWithBlock {
//            (succeeded: Bool, error: NSError?) -> Void in
//            if let error = error {
//                let errorString = error.userInfo["error"] as? NSString
//                // Show the errorString somewhere and let the user try again.
//            } else {
//                callback()
//            }
//        }
//    }
//
//
//    func updateContractorLocation(lat: Float, long: Float) {
//        let point = PFGeoPoint(latitude: lat, longitude: long)
//
//        var currentUser = PFUser.currentUser()
//        currentUser["location"] = point
//        currentUser.saveInBackground()
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // PUSH NOTIFICATIONS:
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        HyperTrack.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        HyperTrack.didFailToRegisterForRemoteNotificationsWithError(error: error)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if (HyperTrack.isHyperTrackNotification(userInfo: userInfo)){
            HyperTrack.didReceiveRemoteNotification(userInfo: userInfo)
            print("PUSH FRMO HT: ", userInfo)
        }
    }


}

