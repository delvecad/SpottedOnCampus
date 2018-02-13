//
//  Post_CommentAPI.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/18/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Post_CommentAPI {
    var REF_POST_COMMENTS = Database.database().reference().child("post-comments")
}
