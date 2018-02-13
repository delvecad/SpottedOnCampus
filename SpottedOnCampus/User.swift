//
//  User.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/10/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation

class User {
    var email: String?
    var profileImageURL: String?
    var username: String?
    var id: String?
    var isFollowing: Bool?
}

extension User {
    static func transformUser(dict: [String: Any], key: String) -> User {
        let user = User()
        user.email = dict["email"] as? String
        user.profileImageURL = dict["profileImageURL"] as? String
        user.username = dict["username"] as? String
        user.id = key
        
        return user
    }
}
