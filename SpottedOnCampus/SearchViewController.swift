//
//  SearchViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 8/1/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    var searchBar = UISearchBar()
    var users: [User] = []

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allows for extension functions
        searchBar.delegate = self
        
        // Setup searchbar style
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = "Search"
        searchBar.frame.size.width = view.frame.size.width - 60
        
        // Place the searchbar on the right side of the navbar
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
//        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
    }

    func doSearch() {
        if let searchText = searchBar.text?.lowercased() {
            API.User.queryUsers(withText: searchText, completion: { (user) in
                
                // Get fresh results
                self.users.removeAll()
                self.tableView.reloadData()
                
                // Get follow state
                self.isFollowing(userID: user.id!, completed: { (value) in
                    user.isFollowing = value
                    self.users.append(user)
                    self.tableView.reloadData()
                })
                
            })
        }
    }
    
    // Tells the segue what to send with it
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // For profile segue
        if segue.identifier == "searchToProfileSegue" {
            let profileVC = segue.destination as! UserProfileViewController
            let userID = sender as! String
            profileVC.userID = userID
            profileVC.delegate = self
        }
    }
    
    // Returns following state
    func isFollowing(userID: String, completed: @escaping (Bool) -> Void) {
        API.Follow.isFollowing(userID: userID, completed: completed)
    }

}


// Handles search bar functions
extension SearchViewController: UISearchBarDelegate {
    
    // Performs an action when the search button is pressed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        doSearch()
    }
    
    // Allows for querying in real time
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doSearch()
    }
}


// Handles table view functions
extension SearchViewController: UITableViewDataSource {
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

extension SearchViewController: PeopleTableViewCellDelegate {
    func goToProfileUserVC(userID: String) {
        performSegue(withIdentifier: "searchToProfileSegue", sender: userID)
    }
}

// Allows for updating follow/unfollow buttons across delegates
extension SearchViewController: ProfileHeaderCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: User) {
        for u in users {
            if u.id == user.id {
                u.isFollowing = user.isFollowing
                self.tableView.reloadData()
            }
        }
    }
}
