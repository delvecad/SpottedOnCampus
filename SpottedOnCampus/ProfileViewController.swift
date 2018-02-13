//
//  ProfileViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 6/18/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var user: User!
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        fetchUser()
        fetchUserPosts()
        
    }
    
    func fetchUser() {
        API.User.observeCurrentUser { (user) in
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView.reloadData()
        }
    }
    
    // Queries posts posted by the current user
    func fetchUserPosts() {
        
        // Grab current user
        guard let user = API.User.CURRENT_USER  else {
            return
        }
        
        API.User_Post.REF_USER_POST.child(user.uid).observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            API.Post.observePost(withId: snapshot.key, completion: { (post) in
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Tells the segue to send user info when segueing back to this view from settings
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // For segue from current user profile
        if segue.identifier == "Profile_SettingSegue" {
            let settingsVC = segue.destination as! SettingsTableViewController
            settingsVC.delegate = self
        }
        
        // For detail segue
        if segue.identifier == "profile_DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postID = sender as! String
            detailVC.postID = postID
        }

    }

}

extension ProfileViewController: UICollectionViewDataSource {
    
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
            headerViewCell.delegateToSettings = self
        }
        
        
        return headerViewCell
    }
    
}

extension ProfileViewController: ProfileHeaderCollectionReusableViewSwitchToSettingsVC {
    func goToSettingsVC() {
        performSegue(withIdentifier: "Profile_SettingSegue", sender: nil)
    }
}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
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

extension ProfileViewController: SettingsTableViewControllerDelegate {
    func updateUserInfo() {
        self.fetchUser()
    }
}


// Determines what happens when a picture is tapped in the collection view
extension ProfileViewController: PhotoCollectionViewCellDelegate {
    func goToDetailVC(postID: String) {
        performSegue(withIdentifier: "profile_DetailSegue", sender: postID)
    }
}
