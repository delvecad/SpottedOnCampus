//
//  SearchViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 6/18/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {
    
    var posts: [Post] = []

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
//        loadTopPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadTopPosts()
    }

    func loadTopPosts() {
        
        self.posts.removeAll()
        
        API.Post.observeTopPosts { (post) in
            self.posts.append(post)
            self.collectionView.reloadData()
        }
    }
    
    
    // Tells the segue what to send with it
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // For detail segue
        if segue.identifier == "discover_DetailSegue" {
            let detailVC = segue.destination as! DetailViewController
            let postID = sender as! String
            detailVC.postID = postID
        }

    }
    

}


extension DiscoverViewController: UICollectionViewDataSource {
    
    // Defines number of cells in the collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    // Defines how each cell looks
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // initializes the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        // gets the cell's corresponding post
        let post = posts[indexPath.row]
        
        // assigns the post to the cell
        cell.post = post
        cell.delegate = self
        
        return cell
    }
    
}

extension DiscoverViewController: UICollectionViewDelegateFlowLayout {
    
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


extension DiscoverViewController: PhotoCollectionViewCellDelegate {
    func goToDetailVC(postID: String) {
        print("Made it this far!")
        performSegue(withIdentifier: "discover_DetailSegue", sender: postID)
    }
}
