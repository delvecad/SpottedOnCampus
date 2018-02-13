//
//  FollowAPI.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/25/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FollowAPI {
    
    // Both in relation to the current user
    var REF_FOLLOWERS = Database.database().reference().child("followers")
    var REF_FOLLOWING = Database.database().reference().child("following")
    
    // Action when follow button is pressed
    func followAction(withID id: String) {
        
        // Update the feed database
        API.User_Post.REF_USER_POST.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            
            // Extract data dictionary from the snapshot
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    
                    // Gets posts of people that the current user follows
                    Database.database().reference().child("feed").child(API.User.CURRENT_USER!.uid).child(key).setValue(true)
                    
                }
            }
        })
        
        // Adds current user to the target's list of followers
        REF_FOLLOWERS.child(id).child(API.User.CURRENT_USER!.uid).setValue(true)
        
        // Adds the target to the current user's list of following
        REF_FOLLOWING.child(API.User.CURRENT_USER!.uid).child(id).setValue(true)
    }

    // Action when unfollow button is pressed
    func unfollowAction(withID id: String) {
        
        // Update the feed database
        API.User_Post.REF_USER_POST.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            
            // Extract data dictionary from the snapshot
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    
                    // Removes posts from feed of user that the current user unfollowed
                    Database.database().reference().child("feed").child(API.User.CURRENT_USER!.uid).child(key).removeValue()
                    
                }
            }
        })
        
        // Removes current user from the target's list of followers
        REF_FOLLOWERS.child(id).child(API.User.CURRENT_USER!.uid).setValue(NSNull())
        
        // Removes the target from the current user's list of following
        REF_FOLLOWING.child(API.User.CURRENT_USER!.uid).child(id).setValue(NSNull())
    }

    // Checks if current user is following the target, and passes the result to the completion block
    func isFollowing(userID: String, completed: @escaping (Bool) -> Void) {
        REF_FOLLOWERS.child(userID).child(API.User.CURRENT_USER!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // if the current user exists in the list of the target's followers
            if let _ = snapshot.value as? NSNull {
                
                completed(false)
                
            }
            else {
                
                completed(true)
                
            }
        })
    }
    
    // Gets the user's follower count
    func fetchFollowerCount(userID: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWERS.child(userID).observe(.value, with: { (snapshot) in
            
            // Get the children count from the snapshot
            let count = Int(snapshot.childrenCount)
            
            // Kick it on back to whoever's asking
            completion(count)
        })
    }
    
    
    // Gets the user's following count
    func fetchFollowingCount(userID: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWING.child(userID).observe(.value, with: { (snapshot) in
            
            // Get the children count from the snapshot
            let count = Int(snapshot.childrenCount)
            
            // You know the drill
            completion(count)
        })
    }
}
