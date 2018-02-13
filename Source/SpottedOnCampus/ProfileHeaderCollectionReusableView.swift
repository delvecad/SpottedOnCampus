//
//  ProfileHeaderCollectionReusableView.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/13/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol ProfileHeaderCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: User)
}

protocol ProfileHeaderCollectionReusableViewSwitchToSettingsVC {
    func goToSettingsVC()
}

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    
    @IBOutlet weak var followButton: UIButton!

    var delegate: ProfileHeaderCollectionReusableViewDelegate?
    var delegateToSettings: ProfileHeaderCollectionReusableViewSwitchToSettingsVC?
    
    var user: User? {
        didSet {
            updateView()
        }
    }
    
    // Queries and displays current user information
    func updateView() {
        
        // Assign the username to the view
        self.usernameLabel.text = user!.username
        
        // If there is a profile image
        if let photoURLString = user!.profileImageURL {
            
            // Convert the URL to a UIImage and assign it to the view
            let photoURL = URL(string: photoURLString)
            self.profileImage.sd_setImage(with: photoURL)
        }
        
        // Set post count
        API.User_Post.fetchPostCount(userID: user!.id!) { (postCount) in
            self.postCount.text = "\(postCount)"
        }
        
        // Set follower count
        API.Follow.fetchFollowerCount(userID: user!.id!) { (followerCount) in
            self.followerCount.text = "\(followerCount)"
        }
        
        // Set following count
        API.Follow.fetchFollowingCount(userID: user!.id!) { (followingCount) in
            self.followingCount.text = "\(followingCount)"
        }
        
        // Configure style of follow button
        followButton.layer.cornerRadius = followButton.frame.height / 2
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = (UIColor.white).cgColor
        
        // Checks if the profile belongs to the current user
        if user?.id == API.User.CURRENT_USER?.uid {
            
            // Sets the title of the button
            followButton.setTitle("Edit Profile", for: .normal)
            
            // Adds a target action that sends the user to the settings view
            followButton.addTarget(self, action: #selector(self.goToSettingsVC), for: UIControlEvents.touchUpInside)
        } else {
            updateStateFollowButton()
        }
        
    }
    
    func updateStateFollowButton() {
        if user!.isFollowing! {
            self.configureUnfollowButton()
        }
        else {
            self.configureFollowButton()
        }
    }
    
    func goToSettingsVC() {
        delegateToSettings?.goToSettingsVC()
    }
    
    // Action when follow button is pressed -> becomes unfollow button
    func follow() {
        if user!.isFollowing == false {
            
            // Follow the user
            API.Follow.followAction(withID: user!.id!)
            
            // Clear out the target action
            self.followButton.removeTarget(self, action: #selector(self.follow), for: UIControlEvents.touchUpInside)
            
            // Set button to prompt for unfollow
            self.configureUnfollowButton()
            
            // Set the cached following status to true
            user!.isFollowing = true
            
            // Change the follow state of the button on VCs acting as delegate
            delegate?.updateFollowButton(forUser: user!)
            
        }
    }
    
    // Action when unfollow button is pressed -> becomes follow button
    func unfollow() {
        if user!.isFollowing == true {
            
            // Unfollow the user
            API.Follow.unfollowAction(withID: user!.id!)
            
            // Clear out the target action
            followButton.removeTarget(self, action: #selector(self.unfollow), for: UIControlEvents.touchUpInside)
            
            // Set button to prompt for follow
            self.configureFollowButton()
            
            // Set the cached following status to false
            user!.isFollowing = false
            
            // Change the follow state of the button on VCs acting as delegate
            delegate?.updateFollowButton(forUser: user!)
        }
    }
    
    func configureUnfollowButton() {
        
        // set look of unfollow button
        self.followButton.setTitle("Following", for: UIControlState.normal)
        self.followButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        // assign the unfollow action to the button
        followButton.addTarget(self, action: #selector(self.unfollow), for: UIControlEvents.touchUpInside)
    }
    
    func configureFollowButton() {
        
        // set look of follow button
        self.followButton.setTitle("Follow", for: UIControlState.normal)
        
        // assign the follow action to the button
        self.followButton.addTarget(self, action: #selector(self.follow), for: UIControlEvents.touchUpInside)
    }
}


