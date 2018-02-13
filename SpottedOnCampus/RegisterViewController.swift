//
//  RegisterViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 6/18/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // username text, tint color, and placeholder text to white
        usernameTextField.tintColor = UIColor.white
        usernameTextField.textColor = UIColor.white
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.7)])
        
        // email text, tint color, and placeholder text to white
        emailTextField.tintColor = UIColor.white
        emailTextField.textColor = UIColor.white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.7)])
        
        // password text, tint color, and placeholder text to white
        passwordTextField.textColor = UIColor.white
        passwordTextField.tintColor = UIColor.white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.7)])
        
        // initialize CALayers
        let bottomLayerUsername = CALayer()
        let bottomLayerEmail = CALayer()
        let bottomLayerPassword = CALayer()
        
        // set dimensions of text field underlines
        bottomLayerUsername.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.5)
        bottomLayerEmail.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.5)
        bottomLayerPassword.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.5)
        
        // set color of underline
        bottomLayerUsername.backgroundColor = UIColor(white: 1.0, alpha: 1).cgColor
        bottomLayerEmail.backgroundColor = UIColor(white: 1.0, alpha: 1).cgColor
        bottomLayerPassword.backgroundColor = UIColor(white: 1.0, alpha: 1).cgColor
        
        // add sublayers to the main layers
        usernameTextField.layer.addSublayer(bottomLayerUsername)
        emailTextField.layer.addSublayer(bottomLayerEmail)
        passwordTextField.layer.addSublayer(bottomLayerPassword)
        
        // round out the profile image placeholder
        profilePicture.layer.cornerRadius = 53
        profilePicture.clipsToBounds = true
        
        // round out signup button, which is initially disabled
        signupButton.isEnabled = false
        signupButton.layer.cornerRadius = 20
        signupButton.clipsToBounds = true
        
        // Executes tap gesture on profile picture placeholder
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleSelectProfilePictureView))
        profilePicture.addGestureRecognizer(tapGesture)
        profilePicture.isUserInteractionEnabled = true
        
        handleTextField()
    }
    
    func handleTextField() {
        usernameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    func textFieldDidChange() {
        guard let username = usernameTextField.text, !username.isEmpty, let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            signupButton.isEnabled = false
            return
        }
        
        signupButton.isEnabled = true
        
    }
    
    func handleSelectProfilePictureView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func dismiss_onClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //disables keyboard once view is touched
        view.endEditing(true)
    }
    
    @IBAction func signupButton_TouchUpInside(_ sender: UIButton) {
        //disables keyboard once signin button is touched
        view.endEditing(true)
        
        if let profileImage = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImage, 0.1) {
            AuthService.signUp(username: usernameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, imageData: imageData,
                               onSuccess: {
                                
                                //Show a success message
                                ProgressHUD.showSuccess("Welcome!")
                                
                                //switch to the main view
                                self.performSegue(withIdentifier: "registerSegue", sender: nil)
            }, onError: {
                (errorString) in
                ProgressHUD.showError(errorString)
                print(errorString!)
            })
        }
        else {
            ProgressHUD.showError("Please select a profile picture")
        }
    }
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did finish picking media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            profilePicture.image = image
        }
        print(info)
        dismiss(animated: true, completion: nil)
    }
}
