//
//  ProfileViewController.swift
//  instaping
//
//  Created by Vítor Vazquez Miguel on 18/05/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import FBSDKLoginKit

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var numberOfPictures: UILabel!
    @IBOutlet weak var numberOfFollowing: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel!
    
    var photoURL : URL?
    var displayName : String?
    var userUid : String?
    
    @IBOutlet weak var userImageCollection: UICollectionView!
    var customImageFlowLayout: CustomCollectionViewFlowLayout!
    
    var ref : DatabaseReference!
    var posts = [PostModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()

        let user = Auth.auth().currentUser
        if let user = user {
            self.photoURL = user.photoURL
            self.displayName = user.displayName
            self.userUid = user.uid
        }
        
        self.profilePicture.sd_setImage(with: photoURL)
        self.profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        self.profilePicture.layer.masksToBounds = true
        self.title = self.displayName
        
        userImageCollection.dataSource = self
        userImageCollection.delegate = self
        
        loadImage()
        
        customImageFlowLayout = CustomCollectionViewFlowLayout()
        userImageCollection.collectionViewLayout = customImageFlowLayout
        userImageCollection.backgroundColor = .black
    }
    
    func loadImage(){
        self.ref?.child("posts").queryOrdered(byChild: "timestamp").observe(.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.posts.removeAll()
                
                for posts in snapshot.children.allObjects as! [DataSnapshot] {
                    let postObject = posts.value as! [String : AnyObject]
                    let id = postObject["id"]
                    let createdBy = postObject["createdBy"]
                    let image = postObject["image"]
                    let storageUUID = postObject["storageUUID"]
                    let subtitle = postObject["subtitle"]
                    let timestamp = postObject["timestamp"]
                    let userUid = postObject["userUid"]
                    
                    let post = PostModel(id: id as? String, createdBy: createdBy as? String, image: image as? String, storageUUID: storageUUID as? String, subtitle: subtitle as? String, timestamp: timestamp as? String, userUid: userUid as? String)
                    
                    self.posts.append(post)
                    self.posts.reverse()
                }
                self.numberOfPictures.text = String(self.posts.count)
                self.userImageCollection.reloadData()
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = userImageCollection.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! ImageCollectionViewCell
        
        let post : PostModel
        post = posts[indexPath.row]
        
        cell.CellImageView.sd_setImage(with: URL(string: post.image!))
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonClicked(_ sender: UIBarButtonItem) {
        
        FBSDKLoginManager().logOut()
        
        UserDefaults.standard.removeObject(forKey: "userSigned")
        UserDefaults.standard.synchronize()
        
        let signUp = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        delegate.window?.rootViewController = signUp
        delegate.rememberLogin()

    }


}
