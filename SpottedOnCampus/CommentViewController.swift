//
//  CommentViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/13/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {

    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    var postID: String!
    var comments = [Comment]()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        
        // Handles tableView specifications
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.dataSource = self
        
        // Sets send button to disabled by default
        reset()
        
        handleTextField()
        
        loadComments()
        
        // Specifies what happens when the keyboard appears and disappears
       
        // Upon showing
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // Upon hiding
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    
    
    
    
    func keyboardWillShow(_ notification: NSNotification) {
        
        // Get dimensions of the keyboard frame
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        // Animate the transition
        UIView.animate(withDuration: 0.2) {
//            self.bottomConstraint.constant = keyboardFrame!.height
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        // Animate the transition
        UIView.animate(withDuration: 0.2) {
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    // Hides tab bar once comment view loads
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // Shows tab bar once comment view is disposed
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Dismisses keyboard when common view is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //disables keyboard once view is touched
        view.endEditing(true)
    }
    
    // sets send button to active or inactive depending on whether textFieldDidChange reports that field is populated
    func handleTextField() {
        commentTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    func textFieldDidChange() {
        if let commentText = commentTextField.text, !commentText.isEmpty {
            self.enableSendButton()
            return
        }
        
        disableSendButton()
    }
    
    func loadComments() {
        API.Post_Comment.REF_POST_COMMENTS.child(self.postID).observe(.childAdded, with: {
            snapshot in
            
            API.Comment.observeComments(withPostId: snapshot.key, completion: { comment in
                
                // Fetch the user
                self.fetchUser(uid: comment.uid!, completed: {
                    
                    //append this comment to the array of comments
                    self.comments.append(comment)
                    
                    // reload the table view to display the new comment
                    self.tableView.reloadData()
                })
            })
        })
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        API.User.observeUser(withId: uid, completion: { user in
            self.users.append(user)
            completed()
        })
    }

    
    
    // Fires when the send button is pressed
    @IBAction func sendButton_TouchUpInside(_ sender: Any) {
        
        // ***********************************************//
        //                                                //
        //     THERE ARE TWO HALVES TO THIS FUNCTION      //
        //         - Upload to comments table             //
        //         - Upload to user-comments table        //
        //                                                //
        //************************************************//
        
        
        // FIRST HALF
        
        
        // Get the reference location to comments
        let commentsReference = API.Comment.REF_COMMENTS
        
        // Create an ID for the comment
        let newCommentID = commentsReference.childByAutoId().key
        
        // Create a reference to the location where the new comment will go
        let newCommentReference = commentsReference.child(newCommentID)
        
        // ensure that the current user exists
        guard let currentUser = API.User.CURRENT_USER else {
            return
        }
        
        // Get the current user's ID
        let currentUserID = currentUser.uid
        
        // Set the value of the new comment's reference to the comment data
        // UPLOADS TO 'COMMENTS"
        newCommentReference.setValue(["uid": currentUserID, "commentText": commentTextField.text!], withCompletionBlock: {
            (error, ref) in
            
            // If there is an error doing this, kick out with an error message
            if error != nil {
                
                //Shows error and kicks out
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            
            
        // SECOND HALF
            
            
            // Get a reference to where we're going to store the post-comment data (with the ID from before)
            let postCommentRef = API.Post_Comment.REF_POST_COMMENTS.child(self.postID).child(newCommentID)
            
            // uploads data to that location
            postCommentRef.setValue(true, withCompletionBlock: { (error, ref) in
                
                // If there's any error, kick out and display a progressHUD error
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            
            // Otherwise, reset the comment text field and set send button to disabled
            self.reset()
            
            // And finally, dismisses the keyboard
            self.view.endEditing(true)
        })
        
    }
    
    
    
    
    
    
    func enableSendButton() {
        sendButton.isEnabled = true
        sendButton.setTitleColor(UIColor.black, for: UIControlState.normal)
    }
    
    func disableSendButton() {
        self.sendButton.isEnabled = false
        self.sendButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
    }
    
    func reset() {
        self.commentTextField.text = ""
        self.disableSendButton()
    }
    
    // Tells the segue what to send with it
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // For profile segue
        if segue.identifier == "commentToProfileSegue" {
            let profileVC = segue.destination as! UserProfileViewController
            let userID = sender as! String
            profileVC.userID = userID
        }
    }

}


extension CommentViewController: UITableViewDataSource, UITableViewDelegate {
    // determines how many cells we want
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    //deternmines how each cell looks
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
        
        let comment = comments[indexPath.row]
        let user = users[indexPath.row]
        
        cell.comment = comment
        cell.user = user
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }
}

extension CommentViewController: CommentTableViewCellDelegate {
    func goToProfileUserVC(userID: String) {
        performSegue(withIdentifier: "commentToProfileSegue", sender: userID)
    }
}




