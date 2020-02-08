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

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var currentUser: User?
    var userToLoadFromSearchVC: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        // Background color
        self.collectionView?.backgroundColor = .white
        
        // Fetch user data
        if userToLoadFromSearchVC == nil {
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
        
        // Set the user in header
        if let user = self.currentUser {
            header.user = user
        } else if let userToLoadFromSearchVC = self.userToLoadFromSearchVC {
            header.user = userToLoadFromSearchVC
            navigationItem.title = userToLoadFromSearchVC.username
        }
    
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
            self.currentUser = user
            self.navigationItem.title = user.username
            self.collectionView?.reloadData()
        }
        
    }
    
    

}
