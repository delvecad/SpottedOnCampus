//
//  HelperService.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/20/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase

class HelperService {
    static func uploadToServer(data: Data, name: String, type: String, size: String, description: String, onSuccess: @escaping () -> Void) {
        
        // Get a reference to the storage service
        let storage = Storage.storage()
        
        // Creates a unique ID for the image being posted
        let photoID = NSUUID().uuidString
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(photoID)
        
        // Upload image to the storage server
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            
            if error != nil {
                
                // Shows error and kicks out
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            // If the upload to storage is successful, upload metadata to the database
            
            // Creates the photo URL
            let photoURL = metadata?.downloadURL()?.absoluteString
            
            // Sends data to the database
            self.sendDataToDatabase(photoURL: photoURL!, name: name, type: type, size: size, description: description, onSuccess: onSuccess)

        }
        
    }
    
    static func sendDataToDatabase(photoURL: String, name: String, type: String, size: String, description: String, onSuccess: @escaping () -> Void) {
        
        let newPostID = API.Post.REF_POST.childByAutoId().key
        let newPostReference = API.Post.REF_POST.child(newPostID)
        
        guard let currentUser = API.User.CURRENT_USER else {
            return
        }
        let currentUserID = currentUser.uid
        
        newPostReference.setValue(["uid": currentUserID, "photoURL": photoURL, "itemName": name, "type": type, "size": size, "description": description, "likeCount": 0], withCompletionBlock: {
            (error, ref) in
            if error != nil {
                
                //Shows error and kicks out
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            // After post is successfully stored on 'post' database, upload post to current user feed
            API.Feed.REF_FEED.child(API.User.CURRENT_USER!.uid).child(newPostID).setValue(true)
            
            // Creates a reference for the post_comment table
            let userPostRef = API.User_Post.REF_USER_POST.child(currentUserID).child(newPostID)
            
            // Assigns a value to the reference
            userPostRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            
            // Upon success
            
            // Shows success message
            ProgressHUD.showSuccess("Success!")
            
            onSuccess()
        })
        
    }
}
