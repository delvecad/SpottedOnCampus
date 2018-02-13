//
//  PostAPI.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/18/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class PostAPI {
    
    // Reference to the "post" table
    var REF_POST = Database.database().reference().child("posts")
    
    // Listens to events at the location of all posts on the database
    func observePosts(completion: @escaping (Post) -> Void) {
        
        REF_POST.observe(.childAdded) { (snapshot: DataSnapshot) in
            // if dict is not null
            if let dict = snapshot.value as? [String: Any] {
                
                // creates the post using the Post class
                let newPost = Post.transformPost(dict: dict, key: snapshot.key)
                
                // Upon completion
                completion(newPost)
            }
        }
    }
    
    func observePost(withId id: String, completion: @escaping (Post) -> Void) {
        REF_POST.child(id).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPost(dict: dict, key: snapshot.key)
                completion(post)
            }
        })
    }
    
    func observeTopPosts(completion: @escaping (Post) -> Void) {
        
        REF_POST.queryOrdered(byChild: "likeCount").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Declare an array of snapshots (reversed to show highest to lowest like counts)
            let snapshotArray = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            
            // For each element in the array
            for child in snapshotArray {
                
                if let dict = child.value as? [String: Any] {
                    
                    let post = Post.transformPost(dict: dict, key: child.key)
                
                    completion(post)
                    
                }
            }
            
            
        })
        
    }
    
    func incrementLikes(postId: String, onSucess: @escaping (Post) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let postRef = API.Post.REF_POST.child(postId)
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = API.User.CURRENT_USER?.uid {
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    likeCount += 1
                    likes[uid] = true
                }
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let post = Post.transformPost(dict: dict, key: snapshot!.key)
                onSucess(post)
            }
        }
    }
    
}
