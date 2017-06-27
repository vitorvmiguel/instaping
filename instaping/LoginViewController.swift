//
//  LoginViewController.swift
//  instaping
//
//  Created by Vítor Vazquez Miguel on 18/05/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    @IBAction func facebookLoginButtonClicked(_ sender: Any) {
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if (error != nil || (result?.isCancelled)!) {
                self.alertError(error: error!)
            } else {
                let credential = FacebookAuthProvider.credential(withAccessToken: (result?.token.tokenString)!)
                Auth.auth().signIn(with: credential) { (user, error) in
                    if (error != nil) {
                        self.alertError(error: error!)
                    }
                    
                    UserDefaults.standard.set(user!.uid, forKey: "userSigned")
                    UserDefaults.standard.synchronize()
                    
                    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.rememberLogin()
                }
            }
        }
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if (user != nil) {
                let ref : DatabaseReference = Database.database().reference()
                let uid = user?.uid as String!
                let photoURL : String = (user?.photoURL?.absoluteString)!
                ref.child("users").child(uid!).setValue(["name": user?.displayName!, "photoURL": photoURL, "userUid": uid!])
            }
        }
    }
    
    @IBAction func signInClicked(_ sender: Any) {
        
        if usernameText.text != "" && passwordText.text != "" {
            Auth.auth().signIn(withEmail: usernameText.text!, password: passwordText.text!, completion: { (user, error) in
                if error != nil {
                    self.alertError(error: error!)
                } else {
                    
                    UserDefaults.standard.set(user!.uid, forKey: "userSigned")
                    UserDefaults.standard.synchronize()
                    
                    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.rememberLogin()
                }
            })
        }
        
    }
    
    func alertError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }


}
