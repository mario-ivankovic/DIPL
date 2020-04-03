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
    
    var selectedImage: UIImage?
    
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
    
    let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSharePost), for: .touchUpInside)
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
    
    // MARK: - UITextView
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard !textView.text.isEmpty else {
            
            shareButton.isEnabled = false
            shareButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        
        shareButton.isEnabled = true
        shareButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
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
    
    @objc func handleSharePost() {
        
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
        view.addSubview(shareButton)
        shareButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 40)
        
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
