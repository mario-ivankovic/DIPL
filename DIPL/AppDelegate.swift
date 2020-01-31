//
//  AppDelegate.swift
//  DIPL
//
//  Created by Mario Ivankovic on 27/01/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Setting our root view controller as our LoginVC
        window = UIWindow()
        window?.rootViewController = UINavigationController(rootViewController: LoginVC())
        
        FirebaseApp.configure()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
}

