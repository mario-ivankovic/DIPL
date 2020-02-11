//
//  UserProfileVC.swift
//  DIPL
//
//  Created by Mario Ivankovic on 01/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    
    
    // MARK: - Properties
    
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        // Background color
        self.collectionView?.backgroundColor = .white
        
        // Fetch user data
        if self.user == nil {
            fetchCurrentUserData()
        }
        
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 200)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // Declare header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        
        // Set delegate
        header.delegate = self
        
        // Set the user in header
        header.user = self.user
        navigationItem.title = user?.username
    
        // Return header
        return header
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        return cell
    }
    
    // MARK: - API
    
    // Retrieving information from database
    func fetchCurrentUserData() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Path to database
        Database.database().reference().child("users").child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView?.reloadData()
        }
        
    }
    
    // MARK: - UserProfileHeader
    
    func handleFollowersTapped(for header: UserProfileHeader) {
        let followVC = FollowVC()
        followVC.viewFollowers = true
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeader) {
        let followVC = FollowVC()
        followVC.viewFollowing = true
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleEditFollowTapped(for header: UserProfileHeader) {
        
        guard let user = header.user else { return }
        
        // Edit profile controller
        if header.editProfileFollowButton.titleLabel?.text == "Edit Profile" {/*
            let editProfileController = EditProfileController()
            editProfileController.user = user
            editProfileController.userProfileController = self
            let navigationController = UINavigationController(rootViewController: editProfileController)
            present(navigationController, animated: true, completion: nil)
            */
        } else {
            
            // Handle user follow/unfollow
            if header.editProfileFollowButton.titleLabel?.text == "Follow" {
                header.editProfileFollowButton.setTitle("Following", for: .normal)
                user.follow()
            } else {
                header.editProfileFollowButton.setTitle("Follow", for: .normal)
                user.unfollow()
            }
        }
    }
    
    func setUserStats(for header: UserProfileHeader) {
        
        guard let uid = header.user?.uid else { return }
        
        var numberOfFollowers: Int!
        var numberOfFollowing: Int!
        
        // Get number of followers
        USER_FOLLOWER_REF.child(uid).observe(.value) { (snapshot) in
            
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowers = snapshot.count
            } else {
                numberOfFollowers = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowers!)\n", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
            
            header.followersLabel.attributedText = attributedText
        }
        
        // Get number of following
        USER_FOLLOWING_REF.child(uid).observe(.value) { (snapshot) in
            
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowing = snapshot.count
            } else {
                numberOfFollowing = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing!)\n", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
            
            header.followingLabel.attributedText = attributedText
        }
    }
    
    

}
