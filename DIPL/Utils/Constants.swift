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

// MARK: - Database references
let USER_REF = DB_REF.child("users")

let USER_FOLLOWER_REF = DB_REF.child("user-followers")
let USER_FOLLOWING_REF = DB_REF.child("user-following")




