//
//  FollowVC.swift
//  DIPL
//
//  Created by Mario Ivankovic on 11/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "FollowCell"

class FollowVC: UITableViewController {
    
    // MARK: -Properties
    
    var viewFollowers = false
    var viewFollowing = false
    var uid: String?
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell class
        tableView.register(FollowCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // Configure nav controller
        if viewFollowers {
            navigationItem.title = "Followers"
        } else {
            navigationItem.title = "Following"
        }
        
        // Clear separator lines
        tableView.separatorColor = .clear
        
        // Fetch users
        fetchUsers()
        
    }
    
    // MARK: -UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowCell
        
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    func fetchUsers() {
        
        guard let uid = self.uid else { return }
        var ref: DatabaseReference!
        
        if viewFollowers {
            
            // Fetch  followers
            ref = USER_FOLLOWER_REF
        } else {
            
            // Fetch following users
            ref = USER_FOLLOWING_REF
        }
        
        ref.child(uid).observe(.childAdded) { (snapshot) in
            
            let userId = snapshot.key
            
            USER_REF.child(userId).observeSingleEvent(of: .value, with:  { (snapshot) in
                
                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
                
                let user = User(uid: userId, dictionary: dictionary)
                self.users.append(user)
                self.tableView.reloadData()

            })
        }
    }
}
