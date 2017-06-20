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
    var postImageURLArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        discoverCollectionView.dataSource = self
        discoverCollectionView.delegate = self
        
        loadImage()
        
        customImageFlowLayout = CustomCollectionViewFlowLayout()
        discoverCollectionView.collectionViewLayout = customImageFlowLayout
        discoverCollectionView.backgroundColor = .black
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DiscoverViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
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
        
        Database.database().reference().child("posts").queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) in
            let posts = snapshot.value! as! NSDictionary
            
            let postIds = posts.allKeys
            
            for id in postIds {
                
                let singlePost = posts[id] as! NSDictionary
                
                self.postImageURLArray.append(singlePost["image"] as! String)
                
                self.discoverCollectionView.reloadData()
            }
        })
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postImageURLArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = discoverCollectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCell", for: indexPath) as! ImageCollectionViewCell
        
        cell.CellImageView.sd_setImage(with: URL(string: self.postImageURLArray[indexPath.row]))
        
        return cell
        
    }

}
