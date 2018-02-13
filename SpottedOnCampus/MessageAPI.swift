//
//  MessageAPI.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 8/15/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation
import FirebaseDatabase

class MessageAPI {
    
    // Reference to the conversations child in the database
    var REF_MESSAGES = Database.database().reference().child("messages")
    
    
    
}
