//
//  User_PostAPI.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/20/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation
import FirebaseDatabase

class User_PostAPI {
    var REF_USER_POST = Database.database().reference().child("user-posts")
    
    func fetchUserPosts(userID: String, completion: @escaping (String) -> Void) {
        REF_USER_POST.child(userID).observe(.childAdded, with: { (snapshot) in
            completion(snapshot.key)
        })
    }
    
    // Get post count of user
    func fetchPostCount(userID: String, completion: @escaping (Int) -> Void) {
        REF_USER_POST.child(userID).observe(.value, with: { (snapshot) in
            
            // Count the number of children the snapshot of the user with userID has
            let count = Int(snapshot.childrenCount)
            
            completion(count)
        })
    }
}
