//
//  CommentTableViewCell.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/14/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit
import SDWebImage

protocol CommentTableViewCellDelegate {
    func goToProfileUserVC(userID: String)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var delegate: CommentTableViewCellDelegate?
    
    var comment: Comment? {
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
        commentLabel.text = comment?.commentText
    }
    
    func setupUserInfo() {
        usernameLabel.text = user?.username
        
        if let photoURLString = user?.profileImageURL {
            let photoURL = URL(string: photoURLString)
            profileImageView.sd_setImage(with: photoURL, placeholderImage: #imageLiteral(resourceName: "userPlaceholder"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set initial values for comments
        usernameLabel.text = ""
        commentLabel.text = ""
        
        // Executes tap gesture on username label
        let tapGestureUsernameLabel = UITapGestureRecognizer(target: self, action: #selector(self.usernameLabel_TouchUpInside))
        usernameLabel.addGestureRecognizer(tapGestureUsernameLabel)
        usernameLabel.isUserInteractionEnabled = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Set placeholder profile image
        profileImageView.image = #imageLiteral(resourceName: "userPlaceholder")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func usernameLabel_TouchUpInside() {
        if let id = user?.id {
            delegate?.goToProfileUserVC(userID: id)
        }
    }

}


