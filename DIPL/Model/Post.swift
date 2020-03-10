//
//  Post.swift
//  DIPL
//
//  Created by Mario Ivankovic on 16/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String?
    var user: User?
    var didLike = false
    
    init(postId: String!, user: User, dictionary: Dictionary<String, AnyObject>) {
        
        self.postId = postId
        
        self.user = user
        
        if let caption = dictionary["caption"] as? String {
            self.caption = caption
        }
        
        if let likes = dictionary["likes"] as? Int {
            self.likes = likes
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        
        if let ownerUid = dictionary["ownerUid"] as? String {
            self.ownerUid = ownerUid
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
    func adjustLikes(addLike: Bool, completion: @escaping(Int) -> ()) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.postId else { return}
        
        if addLike {
            
            // Updates user-likes structure
            USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1], withCompletionBlock: { (err, ref) in
                
                // Updates post-likes structure
                POST_LIKES_REF.child(postId).updateChildValues([currentUid: 1], withCompletionBlock:  { (err, ref) in
                    self.likes = self.likes + 1
                    self.didLike = true
                    completion(self.likes)
                    POSTS_REF.child(postId).child("likes").setValue(self.likes)
                })
            })
            
        } else {
            
            // Remove like from user-like structure
            USER_LIKES_REF.child(currentUid).child(postId).removeValue(completionBlock: { (err, ref) in
                
                // Remove like from post-like structure
                POST_LIKES_REF.child(postId).child(currentUid).removeValue(completionBlock: { (err, ref) in
                    guard self.likes > 0 else { return }
                    self.self.likes = self.likes - 1
                    self.didLike = false
                    completion(self.likes)
                    POSTS_REF.child(postId).child("likes").setValue(self.likes)
                })
            })
        }
    }
}
