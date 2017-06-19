//
//  SecondViewController.swift
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
import AVFoundation
import Photos

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var newPhotoImagePreview: UIImageView!
    @IBOutlet weak var newPhotoButton: UIButton!
    @IBOutlet weak var newPhotoSubtitle: UITextView!    
    @IBOutlet weak var newPhotoUploadButton: UIBarButtonItem!
    var imagePicker: UIImagePickerController!
    var uuid = NSUUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func newPhotoButtonClicked(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            let cameraAction = UIAlertAction(title: "Use Camera", style: .default) { (action) in
                
                let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
                
                if (status == .authorized) {
                    self.displayPicker(type: .camera)
                }
                if (status == .restricted) {
                    self.handleRestricted()
                }
                if (status == .denied) {
                    self.handleDenied()
                }
                if (status == .notDetermined) {
                    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                        if (granted) {
                            self.displayPicker(type: .camera)
                        }
                    })
                }
            }
            alertController.addAction(cameraAction)
        }
        
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
            let cameraRollAction = UIAlertAction(title: "Use Camera Roll", style: .default) { (action) in
                
                let status = PHPhotoLibrary.authorizationStatus()
                
                if (status == .authorized) {
                    self.displayPicker(type: .photoLibrary)
                }
                if (status == .restricted) {
                    self.handleRestricted()
                }
                if (status == .denied) {
                    self.handleDenied()
                }
                if (status == .notDetermined) {
                    PHPhotoLibrary.requestAuthorization({ (status) in
                        if (status == PHAuthorizationStatus.authorized) {
                            self.displayPicker(type: .photoLibrary)
                        }
                    })
                }

                
                
            }
            alertController.addAction(cameraRollAction)
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func displayPicker(type: UIImagePickerControllerSourceType) {
        self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: type)!
        self.imagePicker.sourceType = type
        self.imagePicker.allowsEditing = true
        DispatchQueue.main.async {
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func handleRestricted() {
        let alertController = UIAlertController(title: "Media Access Denied", message: "This device is restricted from access to media in your phone", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func handleDenied() {
        let alertController = UIAlertController(title: "Media Access Denied", message: "This device is restricted from access to media in your phone. Please update your settings", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { (action) in
            DispatchQueue.main.async {
                UIApplication.shared.open(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func uploadPhotoButtonClicked(_ sender: UIBarButtonItem) {
        self.newPhotoUploadButton.isEnabled = false
        
        let mediaFolder = Storage.storage().reference().child("media")
        
        if let photo = UIImageJPEGRepresentation(newPhotoImagePreview.image!, 0.5) {
            mediaFolder.child("\(uuid).jpg").putData(photo, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(ok)
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let imageURL = metadata?.downloadURL()?.absoluteString
                    
                    let photoPost = ["image" : imageURL!, "createdBy" : Auth.auth().currentUser!.displayName!, "uuid" : self.uuid, "subtitle" : self.newPhotoSubtitle.text, "timestamp": ServerValue.timestamp()] as [String : Any]
                    
                    Database.database().reference().child("posts").child((Auth.auth().currentUser?.uid)!).childByAutoId().setValue(photoPost)
                    
                    self.newPhotoImagePreview.image = UIImage(named: "")
                    self.newPhotoSubtitle.text = "Type your subtitle..."
                    self.newPhotoUploadButton.isEnabled = true
                    self.tabBarController?.selectedIndex = 0
                    
                }
            })
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        newPhotoImagePreview.contentMode = .scaleAspectFill
        newPhotoImagePreview.image = chosenImage
        
        dismiss(animated: true, completion: nil)
    }
    

}
