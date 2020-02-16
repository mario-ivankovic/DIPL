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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate that is telling our program that this is the controller that is going to handle all of the stuff for particular screen
        self.delegate = self
        
        // Configure view controllers
        configureViewControllers()
        
        // User validation
        checkIfUserIsLoggedIn()

    }
    
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
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.index(of: viewController)
        
        if index == 2 {
            
            let selectImageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectImageVC)
            navController.navigationBar.tintColor = .black
            
            present(navController, animated: true, completion: nil)
            
            return false
        }
        return true
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
    
}
