//
//  UserProfileHeader.swift
//  DIPL
//
//  Created by Mario Ivankovic on 05/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
    
    // MARK: - Properties
    
    var delegate: UserProfileHeaderDelegate?
    
    // Declaring variable user to be a type user to have access to all attributes asociated with that user
    var user: User? {
        
        didSet {
            
            // Configure edit profile button
            configureEditProfileFollowButton()
            
            // Set user stats
            setUserStats(for: user)
            
            let fullName = user?.name
            nameLabel.text = fullName
            
            guard let profileImageUrl = user?.profileImageUrl else { return }
            
            profileImageView.loadImage(with: profileImageUrl)
        }
    }
    
    // Profile image
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    // Username label
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    // Posts label
    let postsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "\n", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: "Posts", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12),
            NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        
        return label
    }()
    
    // Followers label
    lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "\n", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: "Followers", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12),
            NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        
        // Add gesture recognizer
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        followTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        
        return label
    }()
    
    // Following label
    lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "\n", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: "Following", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12),
            NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        
        // Add gesture recognizer
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        followTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        
        return label
    }()
    
    // Edit profile button
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return button
    }()
    
    // Grid button
    let gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        return button
    }()
    
    // MARK: - Handlers
    
    @objc func handleFollowersTapped() {
        delegate?.handleFollowersTapped(for: self)
    }
    
    @objc func handleFollowingTapped() {
        delegate?.handleFollowingTapped(for: self)
    }
    
    @objc func handleEditProfileFollow() {
        delegate?.handleEditFollowTapped(for: self)
    }
    
    func setUserStats(for user: User?) {
        delegate?.setUserStats(for: self)
    }
    
    func configureBottomToolBar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .lightGray
        
        addSubview(gridButton)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        gridButton.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        topDividerView.anchor(top: gridButton.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        bottomDividerView.anchor(top: gridButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    
    func configureUserStats() {
        
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: nameLabel.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
        
    }
    
    func configureEditProfileFollowButton() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        
        if currentUid == user.uid {
            
            // Configure button as edit profile
            editProfileFollowButton.setTitle("Edit Profile", for: .normal)
            
        } else {
            
            // Configure button as follow button
            editProfileFollowButton.setTitleColor(.white, for: .normal)
            editProfileFollowButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                        
            user.checkIfUserIsFollowed(completion: { (followed) in
                
                if followed {
                    self.editProfileFollowButton.setTitle("Following", for: .normal)
                } else {
                    self.editProfileFollowButton.setTitle("Follow", for: .normal)
                }
            })
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Profile image view
        addSubview(profileImageView)
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 80 , height: 120)
        profileImageView.layer.cornerRadius = 20 / 2
        
        // Username view
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        configureUserStats()
        
        // Edit button view
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 2, paddingLeft: 35, paddingBottom: 0, paddingRight: 35, width: 0, height: 30)
        
        configureBottomToolBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
