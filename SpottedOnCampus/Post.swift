//
//  Post.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/9/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation

class Post {
    var id: String?
    var description: String?
    var photoURL: String?
    var uid: String?
    var likeCount: Int?
    var likes: Dictionary<String, Any>?
    var isLikedByUser: Bool?
}

extension Post {
    static func transformPost(dict: [String: Any], key: String) -> Post {
       
        let post = Post()

        post.id = key
        post.description = dict["description"] as? String
        post.photoURL = dict["photoURL"] as? String
        post.uid = dict["uid"] as? String
        post.likeCount = dict["likeCount"] as? Int
        post.likes = dict["likes"] as? Dictionary<String, Any>
        
        if let currentUserID = API.User.CURRENT_USER?.uid{
            if post.likes != nil {
                post.isLikedByUser = post.likes![currentUserID] != nil
            }
        }
        
        return post
    }
    
    
}
