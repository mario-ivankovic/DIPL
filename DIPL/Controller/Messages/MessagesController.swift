//
//  MessagesController.swift
//  DIPL
//
//  Created by Mario Ivankovic on 29/03/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "MessagesCell"

class MessagesController: UITableViewController {
    
    // MARK: - Properties
    
    var messages = [Message]()
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure nav bar
        configureNavigationBar()
        
        // Register cell
        tableView.register(MessageCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select row")
    }
    
    // MARK: - Handlers
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navigationController = UINavigationController(rootViewController: newMessageController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func showChatController(forUser user: User) {
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    func configureNavigationBar() {
        
        // Navigation title
        navigationItem.title = "Messages"
        
        // Right bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage))
    }
}
