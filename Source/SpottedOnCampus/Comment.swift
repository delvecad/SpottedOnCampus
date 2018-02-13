//
//  Comment.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/17/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation

class Comment {
    var commentText: String?
    var uid: String?
}

extension Comment {
    static func transformComment(dict: [String: Any]) -> Comment {
        
        let comment = Comment()
        
        comment.commentText = dict["commentText"] as? String
        comment.uid = dict["uid"] as? String
        
        return comment
    }
}
