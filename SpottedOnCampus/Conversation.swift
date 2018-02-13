//
//  Conversation.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 8/22/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation

class Conversation {
    var id: String?
    var solicitorID: String?
    var recipientID: String?
}

extension Conversation {
    static func transformConversation(dict: [String: Any], key: String, value: String) -> Conversation {
        let convo = Conversation()

        convo.id = key
        convo.recipientID = value
        
        return convo
    }
}
