//
//  PeopleTableViewCell.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/25/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

protocol PeopleTableViewCellDelegate {
    func goToProfileUserVC(userID: String)
}

class PeopleTableViewCell: UITableViewCell {
    
    var delegate: PeopleTableViewCellDelegate?
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var user: User? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        // Display username
        usernameLabel.text = user?.username
        
        // Display profile picture
        if let profileImageURLString = user?.profileImageURL {
            let imageURL = URL(string: profileImageURLString)
            profileImage.sd_setImage(with: imageURL)
        }
        
        if user!.isFollowing == true {
            self.configureUnfollowButton()
        }
        else {
            self.configureFollowButton()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Executes tap gesture on username label
        let tapGestureComment = UITapGestureRecognizer(target: self, action: #selector(self.usernameLabel_TouchUpInside))
        usernameLabel.addGestureRecognizer(tapGestureComment)
        usernameLabel.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        }
    }
    
    func configureUnfollowButton() {
        // set look of unfollow button
        self.followButton.setTitle("Following", for: UIControlState.normal)
        self.followButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.followButton.layer.borderWidth = 1
        self.followButton.layer.cornerRadius = followButton.frame.height / 2
        self.followButton.layer.borderColor = UIColor(red: 190, green: 134, blue: 4, alpha: 1.0).cgColor
        self.followButton.backgroundColor = UIColor.black
        
        
        // assign the unfollow action to the button
        followButton.addTarget(self, action: #selector(self.unfollow), for: UIControlEvents.touchUpInside)
    }
    
    func configureFollowButton() {
        // set look of follow button
        self.followButton.setTitle("Follow", for: UIControlState.normal)
        self.followButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.followButton.layer.borderWidth = 1
        self.followButton.layer.cornerRadius = followButton.frame.height / 2
        self.followButton.layer.borderColor = UIColor.lightGray.cgColor
        self.followButton.backgroundColor = UIColor.white
        
        // assign the follow action to the button
        self.followButton.addTarget(self, action: #selector(self.follow), for: UIControlEvents.touchUpInside)
    }
    
    func usernameLabel_TouchUpInside() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userID: id)
        }
    }
    
}
