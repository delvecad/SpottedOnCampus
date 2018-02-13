//
//  DetailViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 8/13/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var post = Post()
    var postID = ""
    var user = User()
    var currentUser: User!
    var specifiedPost: Post?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        print("\(postID)")
        loadPost()

        API.User.observeCurrentUser { (user) in
            self.currentUser = user
        }
    }

    func loadPost() {
        
        // Observe the feed of the current user
        API.Post.observePost(withId: postID, completion: { (post) in
            
            // Ensure postUID is not nil
            guard let postUID = post.uid else {
                return
            }
            
            // Fetch the user
            self.fetchUser(uid: postUID, completed: {
                
                //append this post to the array of posts
                self.post = post
                
                // reload the table view to display the new post
                self.tableView.reloadData()
            })
        })
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        API.User.observeUser(withId: uid) { (user) in
            
            // get the result of the observation and set it to the local user variable
            self.user = user
            
            // perform the completion block on success
            completed()
        }
    }
    
    // Tells the segue what to send with it
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // For comment segue
        if segue.identifier == "detail_CommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postID = sender as! String
            commentVC.postID = postID
        }
        
        // For profile segue
        if segue.identifier == "detail_ProfileSegue" {
            let profileVC = segue.destination as! UserProfileViewController
            let userID = sender as! String
            profileVC.userID = userID
        }
        
        // For chat segue, after hitting request button
        if segue.identifier == "chatSegue" {
            
            let chatVC = segue.destination as! ChatViewController
            let convoID = sender as! String
            chatVC.convoID = convoID
            chatVC.senderId = currentUser.id
            chatVC.senderDisplayName = currentUser.username
            chatVC.recieverID = self.specifiedPost?.uid!
            
        }
    }
}

extension DetailViewController: UITableViewDataSource {
    
    // Specifies the number of rows in this view, which should just be one
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Specifies what appears in that row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! HomeTableViewCell
        
        cell.post = post
        cell.user = user
        cell.delegate = self
        
        return cell
    }
}

extension DetailViewController: HomeTableViewCellDelegate {
    func goToCommentVC(postID: String) {
        performSegue(withIdentifier: "detail_CommentSegue", sender: postID)
    }
    
    func goToProfileUserVC(userID: String) {
        performSegue(withIdentifier: "detail_ProfileSegue", sender: userID)
    }
    
    func goToChatVC(convoID: String) {
        performSegue(withIdentifier: "chatSegue", sender: convoID)
    }
    
    func returnPost(post: Post) {
        self.specifiedPost = post
    }
}
