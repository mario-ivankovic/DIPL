//
//  NewMessageController.swift
//  DIPL
//
//  Created by Mario Ivankovic on 29/03/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "NewMessageCell"

class NewMessageController: UITableViewController {
    
    // MARK: - Properties
    
    var users = [User]()
    var messagesController: MessagesController?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure nav bar
        configureNavigationBar()
        
        // Register cell
        tableView.register(NewMessageCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // Fetch users
        fetchUsers()
    }
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NewMessageCell
        
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController?.showChatController(forUser: user)
        }
    }
    
    // MARK: - Handlers
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func configureNavigationBar() {
        
        // Navigation title
        navigationItem.title = "New message"
        
        // Left bar button to be cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        // Left bar button color
        navigationItem.leftBarButtonItem?.tintColor = .black
        
    }
    
    // MARK: - API
    
    func fetchUsers() {
        
        USER_REF.observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            
            if uid != Auth.auth().currentUser?.uid {
                
                Database.fetchUser(with: uid, completion:  { (user) in
                    self.users.append(user)
                    self.tableView.reloadData()
                })
            }
        }
    }
}
