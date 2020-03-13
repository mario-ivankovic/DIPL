//
//  CommentCell.swift
//  DIPL
//
//  Created by Mario Ivankovic on 12/03/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "vodopad", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " Some test comment", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12)]))
        
        attributedText.append(NSAttributedString(string: " 2d", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48 / 2
        
        addSubview(commentLabel)
        commentLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        commentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
