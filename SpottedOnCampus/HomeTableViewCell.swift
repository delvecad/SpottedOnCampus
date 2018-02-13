//
//  HomeTableViewCell.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/10/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

protocol HomeTableViewCellDelegate {
    func goToCommentVC(postID: String)
    func goToProfileUserVC(userID: String)
    func goToChatVC(convoID: String)
    func returnPost(post: Post)
}

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var requestButton: UIButton!
    
    var delegate: HomeTableViewCellDelegate?
    
    var postRef: DatabaseReference!
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    var user: User? {
        didSet {
            setupUserInfo()
        }
    }
    
    func updateView() {
        descriptionLabel.text = post?.description
        if let photoURLString = post?.photoURL {
            let photoURL = URL(string: photoURLString)
            postImageView.sd_setImage(with: photoURL)
        }

        self.updateLike(post: self.post!)
        
        if (post?.uid == API.User.CURRENT_USER?.uid) {
            self.requestButton.isHidden = true
        }
        else{
             self.requestButton.isHidden = false
        }


    }
    
    
    func updateLike(post: Post) {
        if post.isLikedByUser == false || post.isLikedByUser == nil {
            likeImageView.image = UIImage(named: "likeDeselected")
        }
        else {
            likeImageView.image = UIImage(named: "likeSelected")
        }
        
        guard let likeCount = post.likeCount else {
            return
        }
        
        if likeCount > 1 {
            self.likeCountButton.setTitle("\(likeCount) spotters liked this.", for: UIControlState.normal)
        }
        else if likeCount == 1{
            self.likeCountButton.setTitle("\(likeCount) spotter liked this.", for: UIControlState.normal)
        }
        else {
            self.likeCountButton.setTitle("Be the first to like this", for: UIControlState.normal)
        }
    }
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set look of request rental button
//        requestButton.setTitleColor(UIColor.black, for: UIControlState.normal)
//        requestButton.layer.borderWidth = 2
//        requestButton.layer.cornerRadius = requestButton.frame.height / 2
//        requestButton.layer.borderColor = UIColor.lightGray.cgColor
//        requestButton.backgroundColor = UIColor.white
        
        // Set values while cell is loading
        self.descriptionLabel.text = ""
        self.nameLabel.text = ""
        
        // Executes tap gesture on comment button image view
        let tapGestureComment = UITapGestureRecognizer(target: self, action: #selector(self.commentImageView_TouchUpInside))
        commentImageView.addGestureRecognizer(tapGestureComment)
        commentImageView.isUserInteractionEnabled = true
        
        // Executes tap gesture on like button image view
        let tapGestureLike = UITapGestureRecognizer(target: self, action: #selector(self.likeImageView_TouchUpInside))
        likeImageView.addGestureRecognizer(tapGestureLike)
        likeImageView.isUserInteractionEnabled = true
        
        // Executes tap gesture on username label
        let tapGestureNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        nameLabel.addGestureRecognizer(tapGestureNameLabel)
        nameLabel.isUserInteractionEnabled = true
        
        // If it's a post from yourself, disable the rent button
        
    }
    
    
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = UIImage(named: "userPlaceholder")
    }
    
    
    
    
    
    
    // Name Label Action
    func nameLabel_TouchUpInside() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userID: id)
        }
    }
    
    // Comment Button Action
    func commentImageView_TouchUpInside() {
        if let id = post?.id {
            delegate?.goToCommentVC(postID: id)
            print("Comment button pressed")
        }
    }
    
    
    // Like Button Action
    func likeImageView_TouchUpInside() {
        API.Post.incrementLikes(postId: post!.id!, onSucess: { (post) in
            
            // Update the cached post data
            self.updateLike(post: post)
            self.post?.likes = post.likes
            self.post?.likeCount = post.likeCount
            self.post?.isLikedByUser = post.isLikedByUser
            
        }) { (error) in
            ProgressHUD.showError(error)
        }
        
    }
    
    
    // Request Button Action
    @IBAction func requestButton_TouchUpInside(_ sender: UIButton) {
        
        if let uid = post?.uid {
            print("Request button pressed")
            
            triggerRequest()
            
        }
    }
    
    
    
    
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupUserInfo() {
        nameLabel.text = user?.username
        if let profileImageURLString = user?.profileImageURL {
            let imageURL = URL(string: profileImageURLString)
            profileImageView.sd_setImage(with: imageURL)
        }
    }
    
    
    
}




// Database stuff
extension HomeTableViewCell {
    
    func triggerRequest() {
        
        
        
        // If there's already a conversation, find it and continue it
        // Get root ref
        let userRef = API.User.REF_CURRENT_USER!
        
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // if user has convos
            if snapshot.hasChild("convos"){
                
                print()
                
                //
                for child in snapshot.childSnapshot(forPath: "convos").children.allObjects as! [DataSnapshot] {
                    
                    let convoID = child.key as! String
                    let convoPartnerID = child.value as! String
                    
                    print(convoPartnerID)
                    
                    // compare each uid the current user has convos with against the postID
                    if(convoPartnerID == self.post?.uid!) {
                        print("It's a match!")
                        
                        self.delegate?.returnPost(post: self.post!)
                        
                        self.delegate?.goToChatVC(convoID: convoID)
                        
                        return
                    }
                
                }
            
                // if no match was found
                
                // Get the reference location to user convos
                let userConvoReference = userRef.child("convos")
                
                // Create an ID for the comment
                let newConvoID = userConvoReference.childByAutoId().key
                
                self.delegate?.returnPost(post: self.post!)
                
                self.delegate?.goToChatVC(convoID: newConvoID)
                
                
                
                print ("____________________")
                
            }else{
        
                print("no convos yet!")
                
                //PART 1: Convos update
                
                // Get the reference location to user convos
                let userConvoReference = userRef.child("convos")
                
                // Create an ID for the comment
                let newConvoID = userConvoReference.childByAutoId().key
                
                self.delegate?.returnPost(post: self.post!)
                
                self.delegate?.goToChatVC(convoID: newConvoID)

            }
        
        
        
        
        // If there's not, make one and start it by passing a new convo ID to the chatVC
        })

    }
}
