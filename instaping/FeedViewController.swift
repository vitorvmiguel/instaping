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
    
    var userId : String!
    
    var posts = [PostModel]()

    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        self.userId = Auth.auth().currentUser?.uid
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
        imageView.contentMode = .scaleAspectFit
        let logo = UIImage(named: "instaping_logo.pdf")
        imageView.image = logo
        self.navigationItem.titleView = imageView
        
        feedTableView.delegate = self
        feedTableView.dataSource = self
        
        getPostsFromServer()
        
    }
    
    func getPostsFromServer() {
        let dispatchQueue = DispatchQueue(label: "fbQ")
        dispatchQueue.async {

            let requestGroup = DispatchGroup()
            requestGroup.enter()
            self.ref?.child("posts").queryOrdered(byChild: "timestamp").observe(.value, with: { (snapshot) in
                if snapshot.childrenCount > 0 {
                    self.posts.removeAll()
                    
                    for posts in snapshot.children.allObjects as! [DataSnapshot] {
                        let postObject = posts.value as! [String : AnyObject]
                        let post = self.createPost(postObject: postObject)
                        
                        self.posts.append(post)
                        self.posts.reverse()
                    }
                    for post in self.posts {
                        var likesArray = [String]()
                        requestGroup.enter()
                        self.ref?.child("likedBy").child(post.id!).observeSingleEvent(of: .value, with: { (snapshot) in
                            likesArray.removeAll()
                            for likes in snapshot.children.allObjects as! [DataSnapshot] {
                                likesArray.append(likes.key)
                            }
                            post.likesArray = likesArray
                            post.numberOfLikes = String(likesArray.count)
                            requestGroup.leave()
                        })
                    }
                    requestGroup.leave()
                    
                }
            })
            requestGroup.notify(queue: DispatchQueue.main) {
                self.feedTableView.reloadData()
            }
            
        }
        
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
    
    func getFollowers() {
//        self.ref?.child("users").observe(.value, with: {(snapshot) in
//            })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let userUid = Auth.auth().currentUser?.uid
        let post : PostModel
        post = posts[indexPath.row]
        
        let cell = feedTableView.dequeueReusableCell(withIdentifier: "FeedPostCell", for: indexPath) as! FeedTableViewCell
        
        cell.postAuthor.text = post.createdBy
        cell.postSubtitle.text = post.subtitle
        cell.postImage.sd_setImage(with: URL(string: post.image!))
        if((post.likesArray.index(of: userUid!)) != nil) {
            cell.likeButton.setImage(UIImage(named: "liked_like"), for: .normal)
        }
        cell.likesCounter.text = "\(post.numberOfLikes ?? "0") likes"
        
        cell.tapAction = { [weak self] (cell) in
            
            let postId = post.id
            let userId = post.userUid
            
            self!.ref!.child("likedBy").child(postId!).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(userId!) {
                    self!.ref!.child("likedBy").child(postId!).child(userId!).removeValue()
                    post.likesArray.remove(at: post.likesArray.index(of: userUid!)!)
                    post.numberOfLikes = String(post.likesArray.count)
                    cell.likesCounter.text = "\(post.numberOfLikes ?? "0") likes"
                    cell.likeButton.setImage(UIImage(named: "like_white"), for: .normal)
                } else {
                    self!.ref!.child("likedBy").child(postId!).updateChildValues([userId! : true])
                    post.likesArray.append(userUid!)
                    post.numberOfLikes = String(post.likesArray.count)
                    cell.likesCounter.text = "\(post.numberOfLikes ?? "0") likes"
                    cell.likeButton.setImage(UIImage(named: "liked_like"), for: .normal)
                }
            })
        }
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

