//
//  CommentVC.swift
//  DIPL
//
//  Created by Mario Ivankovic on 12/03/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "CommentCell"

class CommentVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell class
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        
        return cell
        
    }
}
