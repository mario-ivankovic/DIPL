//
//  UploadPostVC.swift
//  DIPL
//
//  Created by Mario Ivankovic on 01/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase

class UploadPostVC: UIViewController, UITextViewDelegate {
    
    // MARK: - Properties
    
    enum UploadAction: Int {
        
        case UploadPost
        case SaveChanges
        
        init(index: Int) {
            
            switch index {
            case 0: self = .UploadPost
            case 1: self = .SaveChanges
            default: self = .UploadPost
                
            }
        }
        
    }
    
    var uploadAction: UploadAction!
    var selectedImage: UIImage?
    var postToEdit: Post?
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .blue
        return iv
    }()
    
    let captionTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.groupTableViewBackground
        tv.font = UIFont.systemFont(ofSize: 12)
        return tv
    }()
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleUploadAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure view components
        configureViewComponents()
        
        // Load Image
        loadImage()
        
        // Text view delegate
        captionTextView.delegate = self
        
        view.backgroundColor = .white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if uploadAction == .SaveChanges {
            
            guard let post = self.postToEdit else { return }
            actionButton.setTitle("Save changes", for: .normal)
            self.navigationItem.title = "Edit post"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
            navigationController?.navigationBar.tintColor = .black
            photoImageView.loadImage(with: post.imageUrl)
            captionTextView.text = post.caption
            
        } else {
            
            actionButton.setTitle("Share", for: .normal)
            self.navigationItem.title = "Upload post"

            
        }
        
    }
    
    // MARK: - UITextView
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard !textView.text.isEmpty else {
            
            actionButton.isEnabled = false
            actionButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        
        actionButton.isEnabled = true
        actionButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    
    // MARK: - Handlers
    
    func updateUserFeeds(with postId: String) {
        
        // Current user id
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Database values
        let values = [postId: 1]
        
        // Update follower feeds
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).updateChildValues(values)
            
        }
        
        // Update current user feed
        USER_FEED_REF.child(currentUid).updateChildValues(values)
    }
    
    @objc func handleUploadAction() {
        
        buttonSelector(uploadAction: uploadAction)
        
    }
    
    @objc func handleCancel() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func buttonSelector(uploadAction: UploadAction) {
        
        switch uploadAction {
        
        case .UploadPost:
            handleUploadPost()
        case .SaveChanges:
            handleSavePostChanges()
            
        }
        
    }
    
    func handleSavePostChanges() {
        
        guard let post = self.postToEdit else { return }
        let updatedCaption = captionTextView.text
        
        uploadHashtagToServer(withPostId: post.postId)
        
        POSTS_REF.child(post.postId).child("caption").setValue(updatedCaption) { (err, ref) in
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func handleUploadPost() {
        
        // Parameters
        guard
            let caption = captionTextView.text,
            let postImage = photoImageView.image,
            let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // Image upload data
        guard let uploadData = UIImageJPEGRepresentation(postImage, 0.5) else { return }
        
        // Creation date
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // Update storage
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_POST_IMAGES_REF.child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            
            // Handle error
            if let error = error {
                print("Failed to uplaod image to storage with error", error.localizedDescription)
                return
            }
            
            // Image url
            storageRef.downloadURL(completion: { (url, error) in
                guard let imageUrl = url?.absoluteString else { return }
        
                // Post data
                let values = ["caption": caption,
                              "creationDate": creationDate,
                              "likes": 0,
                              "imageUrl": imageUrl,
                              "ownerUid": currentUid] as [String: Any]
            
                // Post id
                let postId = POSTS_REF.childByAutoId()
                guard let postKey = postId.key else { return }
            
                // Upload information to database
                postId.updateChildValues(values, withCompletionBlock:  { (err, ref) in
                    
                    // Update user post structure
                    let userPostsRef = USER_POSTS_REF.child(currentUid)
                    userPostsRef.updateChildValues([postKey: 1])
                    
                    // Update user-feed structure
                    self.updateUserFeeds(with: postKey)
                    
                    // Upload hashtag to server
                    self.uploadHashtagToServer(withPostId: postKey)
                    
                    // Upload mention notification to server
                    if caption.contains("@") {
                        self.uploadMentionNotification(forPostId: postKey, withText: caption, isForComment: false)
                    }
                
                    // Return to home feed
                    self.dismiss(animated: true, completion: {
                        self.tabBarController?.selectedIndex = 0
                    })
                })
            })
        }
        
    }
    
    func configureViewComponents() {
        view.backgroundColor = .white
        
        // Photo image view
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        
        // Caption text view
        view.addSubview(captionTextView)
        captionTextView.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100)
        
        // Share button
        view.addSubview(actionButton)
        actionButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 40)
        
    }
    
    func loadImage() {
        
        guard let selectedImage = self.selectedImage else { return }
        
        photoImageView.image = selectedImage
        
    }
    
    // MARK: - API
    func uploadHashtagToServer(withPostId postId: String) {
        
        guard let caption = captionTextView.text else { return }
        
        let words: [String] = caption.components(separatedBy: .whitespacesAndNewlines)
        
        for var word in words {
            
            if word.hasPrefix("#") {
                    
                // Making sure that we are getting only letters in our hashtag
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                let hashtagValues = [postId: 1]
                
                // Sending hashtag to database
                HASHTAG_POST_REF.child(word.lowercased()).updateChildValues(hashtagValues)
                
            }
        }
    }
}
