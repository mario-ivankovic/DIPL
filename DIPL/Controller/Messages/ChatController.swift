//
//  ChatController.swift
//  DIPL
//
//  Created by Mario Ivankovic on 29/03/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "ChatCell"

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var user: User?
    var messages = [Message]()
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 55)
        
        containerView.addSubview(sendButton)
        sendButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 0)
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        containerView.addSubview(messageTextField)
        messageTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        containerView.addSubview(separatorView)
        separatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        return containerView
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    let messageTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter message..."
        return tf
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background color
        collectionView?.backgroundColor = .white
        
        // Register cells
        collectionView?.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Configure navigation bar
        configureNavigationBar()
        
        // Observe messages function
        observeMessages()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        
        height = estimateFrameForText(message.messageText).height + 20
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
                
        return cell
    }
    
    // MARK: - Handlers
    
    @objc func handleSend() {
        uploadMesssageToServer()
        
        messageTextField.text = nil
    }
    
    @objc func handleInfoTapped() {
        print("Handle info tapped")
    }
    
    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func configureNavigationBar() {
        
        guard let user = self.user else { return }
        
        navigationItem.title = user.username
        
        // Info button for user profile
        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = .black
        infoButton.addTarget(self, action: #selector(handleInfoTapped), for: .touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        
        navigationItem.rightBarButtonItem = infoBarButtonItem
    }
    
    // MARK: - API
    
    func uploadMesssageToServer() {
        
        guard let messageText = messageTextField.text else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.user else { return }
        guard let uid = user.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let messageValues = ["creationDate": creationDate,
                             "fromId": currentUid,
                             "toId": user.uid,
                             "messageText": messageText] as [String: Any]
        
        let messageRef = MESSAGES_REF.childByAutoId()
        
        guard let messageKey = messageRef.key else { return }
        
        messageRef.updateChildValues(messageValues) { (err,ref) in
        
            USER_MESSAGES_REF.child(currentUid).child(uid).updateChildValues([messageKey: 1])
            USER_MESSAGES_REF.child(uid).child(currentUid).updateChildValues([messageKey: 1])
            
        }

    }
    
    func observeMessages() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let chatPartnerId = self.user?.uid else { return }
        
        USER_MESSAGES_REF.child(currentUid).child(chatPartnerId).observe(.childAdded) { (snapshot) in
            
            let messageId = snapshot.key
            
            self.fetchMessage(withMessageId: messageId)
            
        }
    }
    
    func fetchMessage(withMessageId messageId: String) {
        
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let message = Message(dictionary: dictionary)
            self.messages.append(message)
            self.collectionView?.reloadData()
        }
    }
}
