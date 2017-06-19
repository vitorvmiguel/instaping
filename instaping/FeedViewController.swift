//
//  FirstViewController.swift
//  instaping
//
//  Created by Vítor Vazquez Miguel on 18/05/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SDWebImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var feedTableView: UITableView!
    
    var db: DatabaseReference!
    
    var postSubtitleArray = [String]()
    var postAuthorArray = [String]()
    var postImageURLArray = [String]()
    var postUIDArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
        imageView.contentMode = .scaleAspectFit
        let logo = UIImage(named: "instaping_logo.pdf")
        imageView.image = logo
        self.navigationItem.titleView = imageView
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        getDataFromServer()
    }
    
    func getDataFromServer() {
        self.db = Database.database().reference()
        self.db.child("posts").queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) in
            let posts = snapshot.value! as! NSDictionary
            
            let postIds = posts.allKeys
            
            for id in postIds {
                
                let singlePost = posts[id] as! NSDictionary
                
                self.postAuthorArray.append(singlePost["createdBy"] as! String)
                self.postSubtitleArray.append(singlePost["subtitle"] as! String)
                self.postImageURLArray.append(singlePost["image"] as! String)
                self.postUIDArray.append(id as! String)
                
                self.feedTableView.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postAuthorArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        self.db = Database.database().reference()
        
        let cell = feedTableView.dequeueReusableCell(withIdentifier: "FeedPostCell", for: indexPath) as! FeedTableViewCell
        
        cell.tapAction = { [weak self] (cell) in
            cell.likeButton.setImage(UIImage(named: "liked_like"), for: .normal)
            
            let postId = self?.postUIDArray[indexPath.row]
            let userId = Auth.auth().currentUser?.uid
            
            self?.db.child("likedBy").observeSingleEvent(of: .value, with: { (snapshot) in
                let key = snapshot.key
                if snapshot.hasChild(postId!) {
                    let like = ["\(userId!)" : false]
                    let childUpdates = ["\(key)": like]
                    self?.db.updateChildValues(childUpdates)
                } else {
                    let like = ["\(userId!)" : true]
                    let childUpdates = ["\(key)": like]
                    self?.db.updateChildValues(childUpdates)
                }
            })
        }
        cell.postSubtitle.text = postSubtitleArray[indexPath.row]
        cell.postAuthor.text = postAuthorArray[indexPath.row]
        cell.postImage.sd_setImage(with: URL(string: self.postImageURLArray[indexPath.row]))
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

