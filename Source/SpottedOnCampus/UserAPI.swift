//
//  UserAPI.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/13/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserAPI {
    
    var REF_USERS = Database.database().reference().child("users")
    
    var CURRENT_USER: FirebaseAuth.User? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return currentUser
    }
    
    var REF_CURRENT_USER: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return REF_USERS.child(currentUser.uid)
    }
    
    
    // Query all other users on the database
    func queryUsers(withText text: String, completion: @escaping (User) -> Void) {
        
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryStarting(atValue: text).queryEnding(atValue: text + "\u{f8ff}").queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: {
            
            snapshot in
            
            snapshot.children.forEach({ (s) in
                
                let child = s as! DataSnapshot
                
                if let dict = child.value as? [String: Any] {
                    let user = User.transformUser(dict: dict, key: child.key)
                    completion(user)
                }
                
            })
            
        })
    }
    
    func observeCurrentUser(completion: @escaping (User) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
        
    }
    
    func observeUser(withId uid: String, completion: @escaping (User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user)
            }
        })
    }
    
    func observeUsers(completion: @escaping (User) -> Void) {
        REF_USERS.observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                
                let user = User.transformUser(dict: dict, key: snapshot.key)
                
                // Returns all users not including the current user
                if user.id! != API.User.CURRENT_USER?.uid {
                    completion(user)
                }
            }
        })
    }
}
