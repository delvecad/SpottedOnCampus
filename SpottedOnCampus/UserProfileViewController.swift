//
//  UserProfileViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 8/6/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User!
    var userID = ""
    var posts: [Post] = []
    
    var delegate: ProfileHeaderCollectionReusableViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("userID: \(userID)")

        collectionView.delegate = self
        collectionView.dataSource = self
        
        fetchUser()
        fetchUserPosts()
    }

    func fetchUser() {
        
        // Query using the id of the selected user
        API.User.observeUser(withId: userID) { (user) in
            
            self.isFollowing(userID: user.id!, completed: { (value) in
                
                user.isFollowing = value
                self.user = user
                self.navigationItem.title = user.username
                self.collectionView.reloadData()
            })

        }
        
    }
    
    // Queries posts posted by the current user
    func fetchUserPosts() {
        
        API.User_Post.fetchUserPosts(userID: userID) { (key) in
            API.Post.observePost(withId: key, completion: { (post) in
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        }
    }
    
    func isFollowing(userID: String, completed: @escaping (Bool) -> Void) {
        API.Follow.isFollowing(userID: userID, completed: completed)
    }
    

}


extension UserProfileViewController: UICollectionViewDataSource {
    
    // Defines number of cells in the collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    // Defines how each cell looks
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // initializes the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        // gets the cell's corresponding post
        let post = posts[indexPath.row]
        
        // assigns the post to the cell
        cell.post = post
        
        cell.delegate = self
        
        return cell
    }
    
    // Customizes header view cell
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ProfileHeaderCollectionReusableView", for: indexPath) as! ProfileHeaderCollectionReusableView
        
        // Ensures user is not nil
        if let user = self.user {
            
            // Feeds user data to the ProfileHeaderCollectionReusableView
            headerViewCell.user = user
            headerViewCell.followerCount.text = ""
            headerViewCell.followingCount.text = ""
            headerViewCell.postCount.text = ""
            
            headerViewCell.delegate = self.delegate
            headerViewCell.delegateToSettings = self
        }
        
        
        return headerViewCell
    }
    
    // Tells the segue to send user info when segueing back to this view from settings
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // For segue from current user profile
        if segue.identifier == "ProfileUser_SettingSegue" {
            let settingsVC = segue.destination as! SettingsTableViewController
            settingsVC.delegate = self
        }
        
        // For detail segue
        if segue.identifier == "userProfile_DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postID = sender as! String
            detailVC.postID = postID
        }
        
    }
    
}

extension UserProfileViewController: ProfileHeaderCollectionReusableViewSwitchToSettingsVC {
    func goToSettingsVC() {
        performSegue(withIdentifier: "ProfileUser_SettingSegue", sender: nil)
    }
}

extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    
    // Set width and height of the cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Get dimensions of photos
        let photoWidth = collectionView.frame.size.width / 3 - 1
        let photoHeight = photoWidth
        
        return CGSize(width: photoWidth, height: photoHeight)
    }
    
    // Set vertical spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    // Set horizontal spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension UserProfileViewController: SettingsTableViewControllerDelegate {
    func updateUserInfo() {
        self.fetchUser()
    }
}

// Determines what happens when a picture is tapped in the collection view
extension UserProfileViewController: PhotoCollectionViewCellDelegate {
    func goToDetailVC(postID: String) {
        performSegue(withIdentifier: "userProfile_DetailSegue", sender: postID)
    }
}

