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
    var photoURL : URL?
    var displayName : String?
    var userUid : String?
    
    @IBOutlet weak var userImageCollection: UICollectionView!
    var customImageFlowLayout: CustomCollectionViewFlowLayout!
    var postImageURLArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        Database.database().reference().child("posts").queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) in
            let posts = snapshot.value! as! NSDictionary
            
            let postIds = posts.allKeys
            
            for id in postIds {
                
                let singlePost = posts[id] as! NSDictionary
                
                self.postImageURLArray.append(singlePost["image"] as! String)
                
                self.userImageCollection.reloadData()
            }
        })
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postImageURLArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = userImageCollection.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! ImageCollectionViewCell
        
        cell.CellImageView.sd_setImage(with: URL(string: self.postImageURLArray[indexPath.row]))
        
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
