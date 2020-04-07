//
//  UserProfileVC.swift
//  DIPL
//
//  Created by Mario Ivankovic on 01/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    
    
    // MARK: - Properties
    
    var user: User?
    var posts = [Post]()
    var currentKey: String?
    
    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        // Configure refresh control
        configureRefreshControl()
        
        // Background color
        self.collectionView?.backgroundColor = .white
        
        // Fetch user data
        if self.user == nil {
            fetchCurrentUserData()
        }
        
        // Fetch posts
        fetchPosts()
        
    }
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 320)
    }
    
    // MARK: - UICollectionView
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
           return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if posts.count > 9 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // Declare header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        
        // Set delegate
        header.delegate = self
        
        // Set the user in header
        header.user = self.user
        navigationItem.title = user?.username
    
        // Return header
        return header
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
        
        cell.post = posts[indexPath.item]
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        feedVC.viewSinglePost = true
        
        feedVC.post = posts[indexPath.item]
        
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    // MARK: - UserProfileHeader
    
    func handleFollowersTapped(for header: UserProfileHeader) {
        let followVC = FollowLikeVC()
        followVC.viewingMode = FollowLikeVC.ViewingMode(index: 1)
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeader) {
        let followVC = FollowLikeVC()
        followVC.viewingMode = FollowLikeVC.ViewingMode(index: 0)
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleEditFollowTapped(for header: UserProfileHeader) {
        
        guard let user = header.user else { return }
        
        // Edit profile controller
        if header.editProfileFollowButton.titleLabel?.text == "Edit Profile" {/*
            
            let editProfileController = EditProfileController()
            editProfileController.user = user
            editProfileController.userProfileController = self
            let navigationController = UINavigationController(rootViewController: editProfileController)
            present(navigationController, animated: true, completion: nil)
           */
        } else {
            
            // Handle user follow/unfollow
            if header.editProfileFollowButton.titleLabel?.text == "Follow" {
                header.editProfileFollowButton.setTitle("Following", for: .normal)
                user.follow()
            } else {
                header.editProfileFollowButton.setTitle("Follow", for: .normal)
                user.unfollow()
            }
        }
    }
    
    func setUserStats(for header: UserProfileHeader) {
        
        guard let uid = header.user?.uid else { return }
        
        var numberOfFollowers: Int!
        var numberOfFollowing: Int!
        
        // Get number of followers
        USER_FOLLOWER_REF.child(uid).observe(.value) { (snapshot) in
            
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowers = snapshot.count
            } else {
                numberOfFollowers = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowers!)\n", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 12)])
            attributedText.append(NSAttributedString(string: "Followers", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
            
            header.followersLabel.attributedText = attributedText
        }
        
        // Get number of following
        USER_FOLLOWING_REF.child(uid).observe(.value) { (snapshot) in
            
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowing = snapshot.count
            } else {
                numberOfFollowing = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing!)\n", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 12)])
            attributedText.append(NSAttributedString(string: "Following", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
            
            header.followingLabel.attributedText = attributedText
        }
        
        // Get number of posts
        USER_POSTS_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            let postCount = snapshot.count
            
            let attributedText = NSMutableAttributedString(string: "\(postCount)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
            attributedText.append(NSAttributedString(string: "Posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.postsLabel.attributedText = attributedText
            }
    }
    
    // MARK: - Handlers
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPosts()
        collectionView?.reloadData()
    }
    
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }
    
    // MARK: - API
    
    func fetchPosts() {
        
        var uid: String!
        
        if let user = self.user {
            uid = user.uid
        } else {
            uid = Auth.auth().currentUser?.uid
        }
        
        // Initial data pull
        if currentKey == nil {
            
            USER_POSTS_REF.child(uid).queryLimited(toLast: 10).observeSingleEvent(of: .value, with:  { (snapshot) in
                
                self.collectionView?.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    
                    let postId = snapshot.key
                    self.fetchPost(withPostId: postId)
                })
                self.currentKey = first.key
            })
        } else {
            
            USER_POSTS_REF.child(uid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 7).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    
                    let postId = snapshot.key
                    
                    if postId != self.currentKey {
                        self.fetchPost(withPostId: postId)
                    }
                })
                self.currentKey = first.key
            })
        }
    }
    
    func fetchPost(withPostId postId: String) {
        
        Database.fetchPost(with: postId) { (post) in
            
            self.posts.append(post)
            self.posts.sort(by: { (post1, post2) -> Bool in
                return post1.creationDate > post2.creationDate
            })
            self.collectionView?.reloadData()
        }
        
    }
    
    // Retrieving information from database
    func fetchCurrentUserData() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Path to database
        Database.database().reference().child("users").child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView?.reloadData()
        }
        
    }
}
