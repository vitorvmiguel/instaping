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
import SDWebImage
import FBSDKLoginKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    var photoURL : URL?
    var displayName : String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let user = Auth.auth().currentUser
        if let user = user {
            self.photoURL = user.photoURL
            self.displayName = user.displayName
        }
        
        self.profilePicture.sd_setImage(with: photoURL)
        self.profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        self.profilePicture.layer.masksToBounds = true
        self.title = self.displayName
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
