//
//  NotificationVC.swift
//  DIPL
//
//  Created by Mario Ivankovic on 01/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "NotificaionCell"

class NotificationVC: UITableViewController, NotificationCellDelegate {
    
    // MARK: - Properties
    
    var timer: Timer?
    var currentKey: String?
    var notifications = [Notification]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear separator lines
        tableView.separatorColor = .clear
        
        // Nav title
        navigationItem.title = "Notifications"
        
        // Register cell class
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // Fetch notifications
        fetchNotifications()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if notifications.count > 4 {
            if indexPath.item == notifications.count - 1 {
                fetchNotifications()
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let notification = notifications[indexPath.row]

        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = notification.user
        navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    
    // MARK: - NotificationCellDelegate Protocol
    
    func handleFollowTapped(for cell: NotificationCell) {
        
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            
            // Handle unfollow user
            user.unfollow()
            cell.followButton.configure(didFollow: false)
            
        } else {
            
            // Handle follow user
            user.follow()
            cell.followButton.configure(didFollow: true)
            
        }
        
    }
    
    func handlePostTapped(for cell: NotificationCell) {
        
        guard let post = cell.notification?.post else { return }
        
        let feedController = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedController.viewSinglePost = true
        feedController.post = post
        navigationController?.pushViewController(feedController, animated: true)
        
    }
    
    // MARK: - Handlers
    
    @objc func handleSortNotifications() {
        
        self.notifications.sort { (notification1, notification2) -> Bool in
            return notification1.creationDate > notification2.creationDate
        }
        self.tableView.reloadData()
        
    }
    
    // Gets triggered in certain time intervals to reload our table view data and be populated with information
    func handleReloadTable() {
        
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleSortNotifications), userInfo: nil, repeats: false)
        
    }
    
    // MARK: - API
    
    func fetchNotifications(withNotificationId notificationId: String, dataSnapshot snapshot: DataSnapshot) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
        guard let uid = dictionary["uid"] as? String else { return }
            
        Database.fetchUser(with: uid, completion:  { (user) in
                
            // If notification is for post
            if let postId = dictionary["postId"] as? String {
                    
                Database.fetchPost(with: postId, completion:  { (post) in
                        
                    let notification = Notification(user: user, post: post, dictionary: dictionary)
                    self.notifications.append(notification)
                    self.handleReloadTable()
                })
                    
            } else {
                    
                let notification = Notification(user: user, dictionary: dictionary)
                self.notifications.append(notification)
                self.handleReloadTable()
                
            }
        })
        NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").setValue(1)
        
    }
    
    func fetchNotifications() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if currentKey == nil {
            
            NOTIFICATIONS_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach( { (snapshot) in
                    let notificationId = snapshot.key
                    self.fetchNotifications(withNotificationId: notificationId, dataSnapshot: snapshot)
                })
                self.currentKey = first.key
                
            }
            
        } else {
            
            NOTIFICATIONS_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach( { (snapshot) in
                    let notificationId = snapshot.key
        
                    if notificationId != self.currentKey {
                        self.fetchNotifications(withNotificationId: notificationId, dataSnapshot: snapshot)
                    }
                })
                self.currentKey = first.key
            })
            
        }
        
    }
    
}
