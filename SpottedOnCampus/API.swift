//
//  API.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/18/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation

struct API {
    static var Post = PostAPI()
    static var User = UserAPI()
    static var Comment = CommentAPI()
    static var Post_Comment = Post_CommentAPI()
    static var User_Post = User_PostAPI()
    static var Follow = FollowAPI()
    static var Feed = FeedAPI()
    static var Message = MessageAPI()
    static var Conversation = ConversationAPI()
}
