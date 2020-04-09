//
//  FeedVC.swift
//  DIPL
//
//  Created by Mario Ivankovic on 01/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate {
    
    // MARK: - Properties
    var posts = [Post]()
    var viewSinglePost = false
    var post: Post?
    var currentKey: String?
    var userProfileController: UserProfileVC?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background color
        collectionView?.backgroundColor = .white

        // Register cell classes
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Configure refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        // Configure navigation bar
        configureNavigationBar()
        
        // Fetch posts
        if !viewSinglePost {
            fetchPosts()
        }
        
        updateUserFeeds()
        
    }
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        height += 50
        height += 60
        
        return CGSize(width: width, height: height)
        
    }

    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if posts.count > 4 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
        
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if viewSinglePost {
            return 1
        } else {
            return posts.count
        }
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
    
        cell.delegate = self
        
        if viewSinglePost {
            if let post = self.post {
                cell.post = post
            }
            
        } else {
            cell.post = posts[indexPath.item]
        }
        
        handleHashtagTapped(forCell: cell)
        
        handleUsernameLabelTapped(forCell: cell)
        
        handleMentionTapped(forCell: cell)
        
        return cell
        
    }
    
    // MARK: - FeedCellDelegate Protocol
    
    func handleUsernameTapped(for cell: FeedCell) {
        
        guard let post = cell.post else { return }
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileVC.user = post.user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    
    func handleOptionsTapped(for cell: FeedCell) {
        
        guard let post = cell.post else { return }
        
        if post.ownerUid == Auth.auth().currentUser?.uid {
            
            let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
            
            // Delete post
            alertController.addAction(UIAlertAction(title: "Delete post", style: .destructive, handler: { (_) in
                post.deletePost()
                
                if !self.viewSinglePost {
                    self.handleRefresh()
                } else {
                    
                    if let userProfileController = self.userProfileController {
                        _ = self.navigationController?.popViewController(animated: true)
                        userProfileController.handleRefresh()
                    }
                    
                }
            }))
            
            // Edit post
            alertController.addAction(UIAlertAction(title: "Edit post", style: .default, handler: { (_) in
                print("Edit post")
            }))
            
            // Cancel
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool) {
        
        guard let post = cell.post else { return }
        
        // If the user has already liked the post
        if post.didLike {
            
            // Handle unlike post
            if !isDoubleTap {
                post.adjustLikes(addLike: false, completion: { (likes) in
                    cell.likesLabel.text = "\(likes) likes"
                    cell.likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
                })
            }
        } else {
            
            // Handle like post
            post.adjustLikes(addLike: true, completion: { (likes) in
                cell.likesLabel.text = "\(likes) likes"
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            })
        }
        
    }
    

    func handleShowLikes(for cell: FeedCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        
        let followLikeVC = FollowLikeVC()
        followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 2)
        followLikeVC.postId = postId
        navigationController?.pushViewController(followLikeVC, animated: true)
    }
    
    func handleConfigureLikeButton(for cell: FeedCell) {
        
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            // Check if post id exists in user-like structure
            if snapshot.hasChild(postId) {
                post.didLike = true
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            }
        }
    }
    
    func handleCommentTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
        commentVC.post = post
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
    // MARK: - Handlers
    
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPosts()
        collectionView?.reloadData()
    }
    
    @objc func handleShowMessages() {
        let messagesController = MessagesController()
        navigationController?.pushViewController(messagesController, animated: true)
    }
    
    func handleHashtagTapped(forCell cell: FeedCell) {
        
        cell.captionLabel.handleHashtagTap { (hashtag) in
            let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout())
            hashtagController.hashtag = hashtag
            self.navigationController?.pushViewController(hashtagController, animated: true)
        }
        
    }
    
    func handleMentionTapped(forCell cell: FeedCell) {
        
        cell.captionLabel.handleMentionTap { (username) in
            self.getMentionedUser(withUsername: username)
        }
        
    }
    
    func handleUsernameLabelTapped(forCell cell: FeedCell) {
        
        guard let user = cell.post?.user else { return }
        guard let username = user.username else { return }
        
        let customType = ActiveType.custom(pattern: "^\(username)\\b")

        cell.captionLabel.handleCustomTap(for: customType) { (_) in
            let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileController.user = user
            self.navigationController?.pushViewController(userProfileController, animated: true)
        }
        
    }
    
    func configureNavigationBar() {
        
        if !viewSinglePost {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self, action: #selector(handleShowMessages))
        
        self.navigationItem.title = "Feed"
        
    }
    
    @objc func handleLogout() {
        
        // Declare alert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Add alert log out action
        alertController.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { (_) in
            
            do {
                
                // Attempt sign out
                try Auth.auth().signOut()
                
                // Present login controller
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
                
                print("Successfully logged user out")
                
            }   catch {
                
                // Handle error
                print("Failed to sign out!")
                
            }
            
        }))
        
        // Cancel action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - API
    
    func updateUserFeeds() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_FOLLOWING_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let followingUserId = snapshot.key
            
            USER_POSTS_REF.child(followingUserId).observe(.childAdded, with:  { (snapshot) in
                
                let postId = snapshot.key
                
                USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
            })
        }
        
        USER_POSTS_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let postId = snapshot.key
            
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])

        }
    }
    
    func fetchPosts() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if currentKey == nil {
            
            USER_FEED_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
                
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
            USER_FEED_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value, with: { (snapshot) in
                
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
    
}
