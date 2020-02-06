//
//  User.swift
//  DIPL
//
//  Created by Mario Ivankovic on 06/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

class User {
    
    // Attributes
    var username: String!
    var name: String!
    var profileImageUrl: String!
    var uid: String!
    
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
}
