//
//  Message.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 8/15/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation

class Message {
    var messageText: String?
    var subjectItem: String?
}

extension Message {
    static func transformMessage(dict: [String: Any]) -> Message {
        
        let message = Message()
        
        message.messageText = dict["messageText"] as? String
        message.subjectItem = dict["subjectItem"] as? String
        
        return message
    }
}
