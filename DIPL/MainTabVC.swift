//
//  MainTabVC.swift
//  DIPL
//
//  Created by Mario Ivankovic on 01/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController, UITabBarControllerDelegate {

    // MARK: - Properties
    
    let dot = UIView()
    var notificationIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate that is telling our program that this is the controller that is going to handle all of the stuff for particular screen
        self.delegate = self
        
        // Configure view controllers
        configureViewControllers()
        
        // Configure notification dot
        configureNotificationDot()
        
        // Observe notifications
        observeNotifications()
        
        // User validation
        checkIfUserIsLoggedIn()

    }
    
    // MARK: - Handlers
    
    // Function to create view controller that exist within tab bar controller
    func configureViewControllers() {
        
        // Home feed controller
        let feedVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "anim-home_unselected"), selectedImage: #imageLiteral(resourceName: "anim-home_selected"), rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // Search feed controller
        let searchVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "search-help_unselected"), selectedImage: #imageLiteral(resourceName: "search-help_selected"), rootViewController: SearchVC())
        
        // Select image controller
        let selectImageVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_selected"))
        
        // Notification controller
        let notificationVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "bowl-like_unselected"), selectedImage: #imageLiteral(resourceName: "bowl-like_selected"), rootViewController: NotificationVC())
        
        // Profile controller
        let userProfileVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "user-profile_unselected"), selectedImage: #imageLiteral(resourceName: "user-profile_selected"), rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // View controller to be added to tab controller
        viewControllers = [feedVC, searchVC, selectImageVC, notificationVC, userProfileVC]
        
        // Tab bar tint color
        tabBar.tintColor = .black
        
    }
    
    // Construct navigation controllers
    func constructNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController =
        UIViewController()) -> UINavigationController {
        
        // Construct navigation controller
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .black
        
        // Return nav controller
        return navController
        
    }
    
    func configureNotificationDot() {
        
        if UIDevice().userInterfaceIdiom == .phone {
            
            let tabBarHeight = tabBar.frame.height
            
            if UIScreen.main.nativeBounds.height == 2436 {
                
                // Configure dot for iPhone X
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - tabBarHeight, width: 6, height: 6)
            } else {
                
                // Configure dot for other phone models
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - 16, width: 6, height: 6)

            }
            
            // Create dot
            dot.center.x = (view.frame.width / 5 * 3 + (view.frame.width / 5) / 2)
            dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
            dot.layer.cornerRadius = dot.frame.width / 2
            self.view.addSubview(dot)
            dot.isHidden = true
        }
    }
    
    // MARK: - UITabBar
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.index(of: viewController)
        
        if index == 2 {
            
            let selectImageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectImageVC)
            navController.navigationBar.tintColor = .black
            
            present(navController, animated: true, completion: nil)
            
            return false
            
        } else if index == 3 {
            dot.isHidden = true
            return true
        }
        
        return true
    }
    
    
    // MARK: - API
    
    // Checking if the user is logged in
    func checkIfUserIsLoggedIn() {
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                // Present login controller
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
    }
    
    func observeNotifications() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.notificationIDs.removeAll()
        
        NOTIFICATIONS_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
                
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.forEach({ (snapshot) in
                
                let notificationId = snapshot.key
                
                NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let checked = snapshot.value as? Int else { return }
                    
                    if checked == 0 {
                        self.dot.isHidden = false
                    } else {
                        self.dot.isHidden = true
                    }
                })
            })
        }
    }
}
