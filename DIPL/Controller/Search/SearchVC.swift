//
//  SearchVC.swift
//  DIPL
//
//  Created by Mario Ivankovic on 01/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "SearchUserCell"

class SearchVC: UITableViewController {
    
    // MARK: - Properties
    
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // Separator insets
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        
        // Configure nav controller
        configuraNavCotroller()
        
        // Fetch users
        fetchUsers()
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        
        // Create instance of user profile vc
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        // Passes user from searchVC to userProfileVC
        userProfileVC.user = user
        
        // Push view controller
        navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        
        cell.user = users[indexPath.row]
        
        return cell
        
    }
    
    // MARK: - Handlers
    
    func configuraNavCotroller() {
        navigationItem.title = "Explore"
    }
    
    // MARK: - API
    
    func fetchUsers() {
        
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            
            // Grabing user id so we can construct our user
            let uid = snapshot.key
            
            Database.fetchUser(with: uid, completion: { (user) in
                
                self.users.append(user)
                self.tableView.reloadData()
            })
        }
    }
}
