//
//  FeedAPI.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 8/1/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FeedAPI {
    var REF_FEED = Database.database().reference().child("feed")
    
    func observeFeed(withUserID id: String, completion: @escaping (Post) -> Void) {
        
        // Allows for feed update after following a user
        REF_FEED.child(id).observe(.childAdded, with: {
            snapshot in
            
            let key = snapshot.key
            
            API.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
    
    // Returns post key rather than post object
    func observeFeedRemoved(withUserID id: String, completion: @escaping (Post) -> Void) {
        REF_FEED.child(id).observe(.childRemoved, with: {
            snapshot in
            
            let key = snapshot.key
            
            API.Post.observePost(withId: key, completion: { (post) in
                completion(post)
            })
        })
    }
}
