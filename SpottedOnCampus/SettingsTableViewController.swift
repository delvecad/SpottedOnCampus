//
//  SettingsTableViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 8/10/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

protocol SettingsTableViewControllerDelegate {
    func updateUserInfo()
}

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var delegate: SettingsTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Allows these fields to act as delegates
        usernameTextField.delegate = self
        emailTextField.delegate = self
        
        fetchProfileInfo()
    }
    
    func fetchProfileInfo() {
        API.User.observeCurrentUser { (user) in
            
            // Get username and email
            self.usernameTextField.text = user.username
            self.emailTextField.text = user.email
            
            // Get profile picture
            if let profileURL = URL(string: user.profileImageURL!) {
                self.profilePicture.sd_setImage(with: profileURL)
            }
        }
    }
    @IBAction func editButton_TouchUpInside(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    // Save button action
    @IBAction func saveButton_TouchUpInside(_ sender: UIButton) {
        
        if let profileImage = self.profilePicture.image, let imageData = UIImageJPEGRepresentation(profileImage, 0.1) {
            
            // Let the user know that the data is saving
            ProgressHUD.show("Saving...", interaction: false)
            
            // Send new data to Authentication
            AuthService.updateUserInfo(username: usernameTextField.text!, email: emailTextField.text!, imageData: imageData, onSuccess: {
                
                // Show success notification
                ProgressHUD.showSuccess("Saved!")
                
                // Update user info across views
                self.delegate?.updateUserInfo()
                
                
            }, onError: { (error) in
                ProgressHUD.showError(error)
            })
            
        }
        
    }

    
    // Log out button action
    @IBAction func logoutButton_TouchUpInside(_ sender: UIButton) {
        
        AuthService.logout(onSuccess: {
            let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(loginVC, animated: true, completion: nil)
            print("Signed out")
        }) { (error) in
            ProgressHUD.showError(error)
        }
        
        
    }

}

extension SettingsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print("did finish picking media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            profilePicture.image = image
            
        }
        print(info)
        dismiss(animated: true, completion: nil)
    }
}


// For dismissing the keyboard when the 'done' key is pressed
extension SettingsTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Resigns the textfield's first responder, the keyboard
        textField.resignFirstResponder()
        
        return true
    }
}
