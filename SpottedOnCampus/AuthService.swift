//
//  AuthService.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 6/30/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class AuthService {
    
    
    
    
    
    // Logs in existing user
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        })
    }
    
    
    
    
    
    // Creates new user and signs them up
    static func signUp(username: String, email: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) {(user, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            // Create reusable user id constant
            let uid = user?.uid
            
            // Get a reference to the storage service using the default Firebase App
            let storage = Storage.storage()
            
            // Create a storage reference from our storage service
            let storageRef = storage.reference(forURL: Config.STORAGE_ROOT_REF).child("profile_image").child(uid!)
            
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    onError(error!.localizedDescription)
                    return
                }
                
                let profileImageURL = metadata?.downloadURL()?.absoluteString
                
                self.setUserInformation(profileImageURL: profileImageURL!, username: username, email: email, uid: uid!, onSuccess: onSuccess)
            })
        }
    }
    
    
    
    
    
    // Helper function for signUp() above
    static func setUserInformation(profileImageURL: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        
        //Get reference to database
        var dbRef: DatabaseReference!
        dbRef = Database.database().reference()
        
        let usersReference = dbRef.child("users")
        let newUserReference = usersReference.child(uid)
        
        // set up a new user using this dictionary of user data
        newUserReference.setValue(["username": username, "username_lowercase": username.lowercased(),  "email": email, "profileImageURL": profileImageURL])
        
        // Lets you run a chunk of code after completion. The chunk is taken as a function argument
        onSuccess()
    }
    
    
    
    
    // Similar to signUp(), this function takes new user data entries and replaces them in Authentication
    // Notice that it doesn't take password as an argument. This is based on the settings UI design
    static func updateUserInfo(username: String, email: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        // First, we need to update the email in the Authentication service
        API.User.CURRENT_USER?.updateEmail(to: email, completion: { (error) in
            
            // If there's an error updating, kick out and show the error
            if error != nil {
                onError(error!.localizedDescription)
            }
                
            // Otherwise, go on to the next two steps...
            else {
                
                // There are two other parts to this function: send the pic to the storage db...
                // And send the data to the regular db
                
                // Here's the storage part:
                let uid = API.User.CURRENT_USER?.uid
                
                // Get a reference to the storage service using the default Firebase App
                let storage = Storage.storage()
                
                // Create a storage reference from our storage service
                let storageRef = storage.reference(forURL: Config.STORAGE_ROOT_REF).child("profile_image").child(uid!)
                
                // put the image data on the storage db
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        onError(error!.localizedDescription)
                        return
                    }
                    
                    let profileImageURL = metadata?.downloadURL()?.absoluteString
                    
                    // Time to toss the data in the regular db
                    self.updateDatabase(profileImageURL: profileImageURL!, username: username, email: email, onSuccess: onSuccess, onError: onError)
                })
            }
        })
        
    }
    
    
    
    
    static func updateDatabase(profileImageURL: String, username: String, email: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        // the dictionary that we're going to pass in to update the db with
        let dict = ["username": username, "username_lowercase": username.lowercased(),  "email": email, "profileImageURL": profileImageURL]
        
        
        API.User.REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                onError(error!.localizedDescription)
            }
            else {
                onSuccess()
            }
            
        })
    }
    
    
    
    
    
    // Logout function
    static func logout(onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        do{
            // Try to sign out
            try Auth.auth().signOut()
            onSuccess()
            
        } catch let logoutError {
            onError(logoutError.localizedDescription)
        }
    }
    
}
