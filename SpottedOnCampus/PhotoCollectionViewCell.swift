//
//  PhotoCollectionViewCell.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/20/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

protocol PhotoCollectionViewCellDelegate {
    func goToDetailVC(postID: String)
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    
    var delegate: PhotoCollectionViewCellDelegate?
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let photoURLString = post?.photoURL {
            let photoURL = URL(string: photoURLString)
            photo.sd_setImage(with: photoURL)
        }
        
        // Puts tap gesture recognizer on photo
        let photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.photo_TouchUpInside))
        photo.addGestureRecognizer(photoTapGesture)
        photo.isUserInteractionEnabled = true
    }
    
    // Action performed when the photo is tapped
    func photo_TouchUpInside() {
        if let id = post?.id{
            print("Pic tapped")
            delegate?.goToDetailVC(postID: id)
        }
    }
}
