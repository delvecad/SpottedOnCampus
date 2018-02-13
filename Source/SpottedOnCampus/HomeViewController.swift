//
//  HomeViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 6/18/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var headerLabel: UINavigationItem!
    
    var posts = [Post]()
    var users = [User]()
    var currentUser: User!
    var specifiedPost: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make table view dynamic (to accomodate long posts, etc)
        tableView.estimatedRowHeight = 527
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.dataSource = self
        loadPosts()
        
        let logo = #imageLiteral(resourceName: "Spotted")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        API.User.observeCurrentUser { (user) in
            self.currentUser = user
        }
        
    }
    
    func loadPosts() {
        
        // Starts activity indicator
        self.activityIndicator.startAnimating()
        
        // Observe the feed of the current user
        API.Feed.observeFeed(withUserID: API.User.CURRENT_USER!.uid) { (post) in
            
            // Ensure postID is not nil
            guard let postID = post.uid else {
                return
            }
            
            // Fetch the user
            self.fetchUser(uid: postID, completed: {
                
                //append this post to the array of posts
                self.posts.insert(post, at: 0)
                
                // Hide activity indicator from UI
                self.activityIndicator.hidesWhenStopped = true
                self.activityIndicator.stopAnimating()
                
                // reload the table view to display the new post
                self.tableView.reloadData()
                
            })
            
        }
        
        // Remove posts of users who current user has unfollowed
        API.Feed.observeFeedRemoved(withUserID: API.User.CURRENT_USER!.uid) { (post) in
            
            // for each index in the corresponding post in the post array, if the element has been removed, remove it from array
            self.posts = self.posts.filter { $0.id != post.id }
            
            // Remove user from users array if unfollowed
            self.users = self.users.filter { $0.id != post.uid }
            
            self.tableView.reloadData()
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        API.User.observeUser(withId: uid, completion: { user in
            self.users.insert(user, at: 0)
            completed()
        })
    }

    
    // Tells the segue what to send with it
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // For comment segue
        if segue.identifier == "commentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postID = sender as! String
            commentVC.postID = postID
        }
        
        // For profile segue
        if segue.identifier == "homeToProfileSegue" {
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

extension HomeViewController: UITableViewDataSource {
    // determines how many cells we want
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    //deternmines how each cell looks
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! HomeTableViewCell
        
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        
        cell.post = post
        cell.user = user
        cell.delegate = self

        return cell
    }
}

extension HomeViewController: HomeTableViewCellDelegate {
    func goToCommentVC(postID: String) {
        performSegue(withIdentifier: "commentSegue", sender: postID)
    }
    
    func goToProfileUserVC(userID: String) {
        performSegue(withIdentifier: "homeToProfileSegue", sender: userID)
    }
    
    func goToChatVC(convoID: String) {
        performSegue(withIdentifier: "chatSegue", sender: convoID)
    }
    
    func returnPost(post: Post) {
        self.specifiedPost = post
    }
}
