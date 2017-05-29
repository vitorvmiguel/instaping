//
//  SecondViewController.swift
//  instaping
//
//  Created by Vítor Vazquez Miguel on 18/05/17.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    
    var captureDevice:AVCaptureDevice!
    
    var takePhoto = false

    @IBOutlet weak var newPhotoImagePreview: UIImageView!
    @IBOutlet weak var newPhotoButton: UIButton!
    @IBOutlet weak var newPhotoSubtitle: UITextView!    
    @IBOutlet weak var newPhotoUploadButton: UIBarButtonItem!
    var imagePicker: UIImagePickerController!
    var uuid = NSUUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera,.builtInTelephotoCamera,.builtInDualCamera], mediaType: AVMediaTypeVideo, position: .back).devices {
            captureDevice = availableDevices.first
            beginSession()
        }
    }
    
    func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            self.previewLayer = previewLayer
            self.view.layer.addSublayer(self.previewLayer)
            self.previewLayer.frame = self.view.layer.frame
            
            captureSession.startRunning()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "tech.bts.instaping.captureQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
        }
        
    }
    
    @IBAction func takePhotoButtonPressed(_ sender: UIButton) {
        takePhoto = true
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        if takePhoto {
            takePhoto = false
            
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                
                let photoViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
                
                photoViewController.takenPhoto = image
                
                DispatchQueue.main.async {
                    self.present(photoViewController, animated: true, completion: {
                    self.stopCaptureSession()
                    })
                }
            }
        }
    }
    
    func getImageFromSampleBuffer(buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRectangle = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRectangle) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
    func stopCaptureSession() {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
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
                    
                    let photoPost = ["image" : imageURL!, "createdBy" : Auth.auth().currentUser!.email!, "uuid" : self.uuid, "subtitle" : self.newPhotoSubtitle.text] as [String : Any]
                    
                    Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("posts").childByAutoId().setValue(photoPost)
                    
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
