//
//  DiscoverDetailViewController.swift
//  instaping
//
//  Created by Vítor Vazquez Miguel on 26/06/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class DiscoverDetailViewController: UIViewController {

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var followButton: UIButton!

    var post : PostModel?
    var ref : DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        postImage.sd_setImage(with: URL(string: (post?.image!)!))
        
    }
    @IBAction func followButtonClicked(_ sender: UIButton) {
            
            let postUserId = self.post?.userUid
            let currentUserId = Auth.auth().currentUser?.uid
            
            self.ref!.child("follows").child(currentUserId!).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(postUserId!) {
                    self.ref!.child("follows").child(currentUserId!).child(postUserId!).removeValue()
                    self.ref!.child("followedBy").child(postUserId!).child(currentUserId!).removeValue()
                    self.followButton.setTitle("Follow", for: .normal)

                } else {
                    self.ref!.child("follows").child(currentUserId!).updateChildValues([postUserId! : true])
                    self.ref!.child("followedBy").child(postUserId!).updateChildValues([currentUserId! : true])
                    self.followButton.setTitle("Unfollow", for: .normal)
                }
            })
        
    }
}
