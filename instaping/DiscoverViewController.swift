//
//  FavoritesViewController.swift
//  instaping
//
//  Created by Vítor Vazquez Miguel on 18/05/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

class DiscoverViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var discoverCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var customImageFlowLayout: CustomCollectionViewFlowLayout!
    
    var posts = [PostModel]()
    var userUid : String?
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userUid = Auth.auth().currentUser?.uid
        self.ref = Database.database().reference()

        searchBar.delegate = self
        
        discoverCollectionView.dataSource = self
        discoverCollectionView.delegate = self
        
        loadImage()
        
        customImageFlowLayout = CustomCollectionViewFlowLayout()
        discoverCollectionView.collectionViewLayout = customImageFlowLayout
        discoverCollectionView.backgroundColor = .black
        
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DiscoverViewController.dismissKeyboard))
        //view.addGestureRecognizer(tap)
    }

    func dismissKeyboard() {
        view.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        //TODO search
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImage(){
        self.ref?.child("posts").queryOrdered(byChild: "timestamp").observe(.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.posts.removeAll()
                
                for posts in snapshot.children.allObjects as! [DataSnapshot] {
                    let postObject = posts.value as! [String : AnyObject]
                    let post = self.createPost(postObject: postObject)
                    if (post.userUid != self.userUid) {
                        self.posts.append(post)
                    }
                    self.posts.reverse()
                }
                
                self.discoverCollectionView.reloadData()
            }
        })
    }
    
    func createPost(postObject: [String: AnyObject]) -> PostModel {
        let id = postObject["id"]
        let createdBy = postObject["createdBy"]
        let image = postObject["image"]
        let storageUUID = postObject["storageUUID"]
        let subtitle = postObject["subtitle"]
        let timestamp = postObject["timestamp"]
        let userUid = postObject["userUid"]
        return PostModel(id: id as? String, createdBy: createdBy as? String, image: image as? String, storageUUID: storageUUID as? String, subtitle: subtitle as? String, timestamp: timestamp as? String, userUid: userUid as? String)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = discoverCollectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCell", for: indexPath) as! ImageCollectionViewCell
        
        let post : PostModel

        post = posts[indexPath.row]
            
        cell.CellImageView.sd_setImage(with: URL(string: post.image!))
        
        return cell
        
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.item]
        performSegue(withIdentifier: "ToDetail", sender: post)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToDetail" {
            if let dest = segue.destination as? DiscoverDetailViewController,
                let post = sender as? PostModel {
                dest.post = post
            }
        }
    }
    
}
