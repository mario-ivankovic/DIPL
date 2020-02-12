//
//  Extensions.swift
//  DIPL
//
//  Created by Mario Ivankovic on 28/01/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase

extension UIView {
    
    
    // Function that every time we call it's going to allow us to place our view components wherever we would like to on the screen
    // Based on all of these input parameters that we have set
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,
                paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

var imageCache = [String: UIImage]()

extension UIImageView {
    
    // Function to load our profile image with input parameter URL string
    func loadImage(with urlString: String) {
        
        // Check if image exists in cache
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        // URL for image location
        guard let url = URL(string: urlString) else { return }
        
        // Fetch contents of URL
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // Handle error
            if let error = error {
                print("Failed to load image with error", error.localizedDescription)
            }
            
            // Image data
            guard let imageData = data else { return }
            
            // Create image using image data
            let photoImage = UIImage(data: imageData)
            
            // Set key and value for image cache
            imageCache[url.absoluteString] = photoImage
            
            // Set image
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
    }
}

extension Database {
    
    static func fetchUser(with uid: String, completion: @escaping(User) -> ()) {
        
        USER_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            
            completion(user)
        }
    }
}
