//
//  CustomImageView.swift
//  DIPL
//
//  Created by Mario Ivankovic on 17/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastImageUrlUsedToLoadImage: String?
    
    func loadImage(with urlString: String) {
        
        // Set image to nil
        self.image = nil
        
        // Set lastImageUrlUsedToLoadImage
        lastImageUrlUsedToLoadImage = urlString
        
        // Check if image exists in cache
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        // url for image location
        guard let url = URL(string: urlString) else { return }
        
        // Fetch contents of URL
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // Handle error
            if let error = error {
                print("Failed to load image with error", error.localizedDescription)
            }
            
            if self.lastImageUrlUsedToLoadImage != url.absoluteString {
                return
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
