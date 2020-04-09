//
//  SelectImageVC.swift
//  DIPL
//
//  Created by Mario Ivankovic on 14/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "SelectPhotoCell"
private let headerIdentifier = "SelectPhotoHeader"

class SelectImageVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var images = [UIImage]()
    var assets = [PHAsset]()
    var selectedImage: UIImage?
    var header: SelectPhotoHeader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        collectionView?.register(SelectPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        collectionView?.backgroundColor = .white
        
        // Configure nav buttons
        configureNavigationButton()
        
        // Fetch photos
        fetchPhotos()
    }
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! SelectPhotoHeader
        
        self.header = header
        
        if let selectedImage = self.selectedImage {
            
            // Index of selected image
            if let index = self.images.index(of: selectedImage) {
                
                // Asset associated with selected image
                let selectedAsset = self.assets[index]
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                
                // Request image
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
                    
                    header.photoImageView.image = image
                }
            }
        }
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SelectPhotoCell
        
        cell.photoImageView.image = images[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedImage = images[indexPath.row]
        self.collectionView?.reloadData()
        
        // First item in out collection view
        let indexPath = IndexPath(item: 0, section: 0)
        
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        
    }
    
    // MARK: - Handlers
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNext() {
        
        let uploadPostVC = UploadPostVC()
        uploadPostVC.selectedImage = header?.photoImageView.image
        uploadPostVC.uploadAction = UploadPostVC.UploadAction(index: 0)
        navigationController?.pushViewController(uploadPostVC, animated: true)
        
    }
    
    // Cancel and next buttons
    func configureNavigationButton() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))

    }
    
    func getAssetFetchOptions() -> PHFetchOptions {
        
        let options = PHFetchOptions()
        
        // Fetch limit
        options.fetchLimit = 30
        
        // Sort photos by date
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        
        // Set sort descriptor for options
        options.sortDescriptors = [sortDescriptor]
        
        // Return options
        return options
    }
    
    func fetchPhotos() {
        
        // PHAsset is going to grab all of the images from our photo library on our device
        let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
        
        // Fetch images on background thread
        DispatchQueue.global(qos: .background).async {
            
            // Enumerate objects
            allPhotos.enumerateObjects({ (asset, count, stop) in
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                // Request image representation for specified asset
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler:  { (image, info) in
                    
                    if let image = image {
                        
                        // Append image to data source
                        self.images.append(image)
                        
                        // Append asset to data source
                        self.assets.append(asset)
                        
                        // Set selected image with first image
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                        
                        // Reload collection view with images once has completed
                        if count == allPhotos.count - 1 {
                            
                            // Reload collection view on main thread
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        }
                        
                        
                    }
                })
            })
        }
    }
}
