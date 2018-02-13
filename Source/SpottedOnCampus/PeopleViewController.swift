//
//  PeopleViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 7/25/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var users: [User] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUsers()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileSegue" {
            let profileVC = segue.destination as! UserProfileViewController
            let userID = sender as! String
            profileVC.userID = userID
            
            // set the delegate of UserProfile VC to be this VC
            profileVC.delegate = self
            
//            self.tableView.reloadData()
        }
    }
    
    
    
    func loadUsers() {
        API.User.observeUsers { (user) in
            self.isFollowing(userID: user.id!, completed: { (value) in
                user.isFollowing = value
                self.users.append(user)
                self.tableView.reloadData()
            })
        }
    }
    
    func isFollowing(userID: String, completed: @escaping (Bool) -> Void) {
        API.Follow.isFollowing(userID: userID, completed: completed)
    }

}


extension PeopleViewController: UITableViewDataSource {
    // determines how many cells we want
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    //deternmines how each cell looks
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        
        // Pull user data from cache and feed it to the cell when it loads
        let user = users[indexPath.row]
        cell.user = user
        cell.delegate = self
        
        return cell
    }
}

extension PeopleViewController: PeopleTableViewCellDelegate {
    func goToProfileUserVC(userID: String) {
        performSegue(withIdentifier: "profileSegue", sender: userID)
    }
}

// Allows for updating follow/unfollow buttons across delegates
extension PeopleViewController: ProfileHeaderCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: User) {
        for u in users {
            if u.id == user.id {
                u.isFollowing = user.isFollowing
                self.tableView.reloadData()
            }
        }
    }
}

