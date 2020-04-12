//
//  CommentInputTextView.swift
//  DIPL
//
//  Created by Mario Ivankovic on 12/04/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {

    // MARK: - Properties
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter comment.."
        label.textColor = .lightGray
        return label
    }()

    // MARK: - Init
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInputTextChange), name: .UITextViewTextDidChange, object: nil)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handlers
    
    @objc func handleInputTextChange() {
        
        placeholderLabel.isHidden = !self.text.isEmpty
        
    }
}
