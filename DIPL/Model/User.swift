//
//  User.swift
//  DIPL
//
//  Created by Mario Ivankovic on 06/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import Firebase

class User {
    
    // Attributes
    var username: String!
    var name: String!
    var profileImageUrl: String!
    var uid: String!
    var isFollowed = false
    
    init(uid: String, dictionary: Dictionary<String, AnyObject>) {
        
        self.uid = uid
        
        if let username = dictionary["username"] as? String {
            self.username = username
        }
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
    }
    
    func follow() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        guard let uid = uid else { return }
        
        // Set is followed to true
        self.isFollowed = true
        
        // Adding followed user to current user-following structure
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1])
        
        // Adding current user to followed user-follower structure
        USER_FOLLOWER_REF.child(uid).updateChildValues([currentUid: 1])
        
        // Upload follow notification to server
        // uploadFollowNotificationToServer()
    }
    
    func unfollow() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        guard let uid = uid else { return }
        
        // Set is followed to false
        self.isFollowed = false
        
        // Removing followed user from current user-following structure
        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue()
        
        // Remove current user from followed user-follower structure
        USER_FOLLOWER_REF.child(uid).child(currentUid).removeValue()
    }
    
    func checkIfUserIsFollowed(completion: @escaping(Bool) ->()) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_FOLLOWING_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.hasChild(self.uid) {
                self.isFollowed = true
                completion(true)
            } else {
                self.isFollowed = false
                completion(false)
            }
        }
        
    }
}
