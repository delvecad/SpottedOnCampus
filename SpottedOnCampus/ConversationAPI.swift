//
//  ConversationAPI.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 8/17/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ConversationAPI {
    
    var REF_CONVOS = Database.database().reference().child("users").child((API.User.CURRENT_USER?.uid)!).child("convos")

    
    func observeConvos(withId id: String, completion: @escaping (Conversation) -> Void) {
        REF_CONVOS.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            
            print("made it to conversations")
            
//            if let dict = snapshot.value as? [String: Any] {
                print("snapshot value: \(snapshot.value!)")
            
            let dict = [snapshot.key : snapshot.value!]
            print("dict: \(dict)")
                let newConvo = Conversation.transformConversation(dict: dict, key: snapshot.key, value: snapshot.value as! String)
                completion(newConvo)
//            }
        })
    }
    
}
