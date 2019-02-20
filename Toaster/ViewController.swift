//
//  ViewController.swift
//  Toaster
//
//  Created by Ash Cortez on 2/12/19.
//  Copyright © 2019 Turby_Turby. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AppCenter
import AppCenterCrashes

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MSCrashesDelegate {
    
    var imagePickerController = UIImagePickerController()
    var crashesEnabled = MSCrashes.isEnabled()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePicker()
        if (crashesEnabled) {
            setupMSCrashes()
        }
    }
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender.title(for: .normal) == "Upload Video" {
            showImagePicker(sourceType: UIImagePickerController.SourceType.photoLibrary)
        } else if sender.title(for: .normal) == "Create New Video" {
            showImagePickerForCamera()
        } else if sender.title(for: .normal) == "Crash the App" {
            forceCrash()
        }
    }
    
    func setupImagePicker() {
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
    }
    
    func showImagePickerForCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        if authStatus == AVAuthorizationStatus.denied {
            // Denied access to camera, alert the user.
            // The user has previously denied access. Remind the user that we need camera access to be useful.
            let alert = UIAlertController(title: "Unable to access the Camera",
                                          message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.",
                                          preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
                // Take the user to Settings app to possibly change permission.
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        // Finished opening URL
                    })
                }
            })
            
            alert.addAction(okAction)
            alert.addAction(settingsAction)
            
            present(alert, animated: true, completion: nil)
        }
        else if (authStatus == AVAuthorizationStatus.notDetermined) {
            // The user has not yet been presented with the option to grant access to the camera hardware.
            // Ask for permission.
            //
            // (Note: you can test for this case by deleting the app on the device, if already installed).
            // (Note: we need a usage description in our Info.plist to request access.
            //
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.showImagePicker(sourceType: UIImagePickerController.SourceType.camera)
                    }
                }
            })
        } else {
            // Allowed access to camera, go ahead and present the UIImagePickerController.
            showImagePicker(sourceType: UIImagePickerController.SourceType.camera)
        }
    }
    
    fileprivate func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        imagePickerController.sourceType = sourceType
        if  (imagePickerController.sourceType == .camera) {
            imagePickerController.cameraCaptureMode = .video
            imagePickerController.cameraDevice = .front
        }
        present(imagePickerController, animated: true, completion: {
            // Done presenting.
        })
    }
    
// MARK: - Crash code for demos
    
    func forceCrash() {
        MSCrashes.generateTestCrash()
    }
    
    func setupMSCrashes() {
        MSCrashes.setDelegate(self)
        
        MSCrashes.setUserConfirmationHandler({ (errorReports: [MSErrorReport]) in
            
            // Your code to present your UI to the user, e.g. an UIAlertController.
            let alertController = UIAlertController(title: "Sorry about that!",
                                                    message: "Do you want to send an anonymous crash report so we can fix the issue?",
                                                    preferredStyle:.alert)
            
            alertController.addAction(UIAlertAction(title: "Don't send", style: .cancel) {_ in
                MSCrashes.notify(with: .dontSend)
            })
            
            alertController.addAction(UIAlertAction(title: "Send", style: .default) {_ in
                MSCrashes.notify(with: .send)
            })
            
            alertController.addAction(UIAlertAction(title: "Always send", style: .default) {_ in
                MSCrashes.notify(with: .always)
            })
            
            // Show the alert controller.
            self.present(alertController, animated: true)
            return true // Return true if the SDK should await user confirmation, otherwise return false.
        })
        if (MSCrashes.hasCrashedInLastSession()){
        }
    }

// MARK: - UIImagePickerControllerDelegate
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: {
            // Done cancel dismiss of image picker.
        })
    }
    

// MARK: - MSCrashesDelegate

    
    func crashes(_ crashes: MSCrashes!, shouldProcessErrorReport errorReport: MSErrorReport!) -> Bool {
        return true; // return true if the crash report should be processed, otherwise false.
    }
    
}



