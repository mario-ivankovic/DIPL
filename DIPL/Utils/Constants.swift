//
//  Constants.swift
//  DIPL
//
//  Created by Mario Ivankovic on 10/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import Firebase

// MARK: - Root references
let DB_REF = Database.database().reference()
let STORAGE_REF = Storage.storage().reference()

// MARK: - Image storage references
let STORAGE_PROFILE_IMAGES_REF = STORAGE_REF.child("profile_images")
let STORAGE_POST_IMAGES_REF = STORAGE_REF.child("post_images")

// MARK: - Database references
let USER_REF = DB_REF.child("users")

// MARK: - User following references
let USER_FOLLOWER_REF = DB_REF.child("user-followers")
let USER_FOLLOWING_REF = DB_REF.child("user-following")

// MARK: - Posts reference
let POSTS_REF = DB_REF.child("posts")
let USER_POSTS_REF = DB_REF.child("user-posts")

// MARK: - User feed reference
let USER_FEED_REF = DB_REF.child("user-feed")

// MARK: - Likes reference
let USER_LIKES_REF = DB_REF.child("user-likes")
let POST_LIKES_REF = DB_REF.child("post-likes")

// MARK: - Comment reference
let COMMENT_REF = DB_REF.child("comments")

// MARK: - Notifications reference
let NOTIFICATIONS_REF = DB_REF.child("notifications")

// MARK: - Messages reference
let MESSAGES_REF = DB_REF.child("messages")
let USER_MESSAGES_REF = DB_REF.child("user-messages")

// MARK: - Hashtag reference
let HASHTAG_POST_REF = DB_REF.child("hashtag-post")

// MARK: - Like, comment, follow values
let LIKE_INT_VALUE = 0
let COMMENT_INT_VALUE = 1
let FOLLOW_INT_VALUE = 2
let COMMENT_MENTION_INT_VALUE = 3
let POST_MENTION_INT_VALUE = 4


