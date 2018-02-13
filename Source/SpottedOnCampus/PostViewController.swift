//
//  CameraViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 6/18/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!

    
    
//    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var selectedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // round out the image placeholder
        photo.layer.cornerRadius = 10
        photo.clipsToBounds = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showActionSheet))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
        
        
        // Specifies what happens when the keyboard appears and disappears
        
        // Upon showing
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // Upon hiding
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        handlePost()
    }
    
    
    
    
    
    // Disables or enables post button depending on content presence
    func handlePost() {
        
        if selectedImage != nil && itemNameTextField.text != nil && sizeTextField.text != nil && typeTextField.text != nil && descriptionTextView.text != nil {
            postButton.isEnabled = true
            postButton.alpha = 1
        }
        else {
            postButton.isEnabled = false
            postButton.alpha = 0.7
        }
    }
    
    
    
    
    
    func showActionSheet() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Creates cancel button
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            print("Cancel")
        }
        // Assigns cancel button action
        actionSheetController.addAction(cancelActionButton)
        
        // Creates camera button
        let cameraActionButton = UIAlertAction(title: "Image From Camera", style: .default)
        { _ in
            print("Camera")
        }
        // Assigns camera button action
        actionSheetController.addAction(cameraActionButton)
        
        // Creates library button action
        let libraryActionButton = UIAlertAction(title: "Image From Library", style: .default)
        { _ in
            print("Library")
            self.present(pickerController, animated: true, completion: nil)
        }
        // Assigns library button action
        actionSheetController.addAction(libraryActionButton)
        
        if selectedImage != nil {
            // Creates remove picture button
            let removeActionButton = UIAlertAction(title: "Remove Image", style: .destructive)
            { _ in
                self.photo.image = #imageLiteral(resourceName: "postPlaceholder")
            }
            // Assigns remove action
            actionSheetController.addAction(removeActionButton)
        }
        
        // Presents the action sheet after it is created above
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    
    
    
    
    // Clears image and text when pressed
    @IBAction func clearButton_TouchUpInside(_ sender: UIBarButtonItem) {
        self.cleanUp()
        self.handlePost()
    }
    
    
    
    
    
    // Clears the image and the text
    func cleanUp() {
        
        // Set the image back to the placeholder image
        self.photo.image = #imageLiteral(resourceName: "postPlaceholder")
        
        // Clear out the selected image variable
        self.selectedImage = nil
        
        // Clear out the fields
        self.descriptionTextView.text = nil
        self.itemNameTextField.text = nil
        self.sizeTextField.text = nil
        self.typeTextField.text = nil
        
        // Disable the post button again
        
    }
    
    
    
    

    @IBAction func postButton_TouchUpInside(_ sender: Any) {
        
        if let profileImage = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImage, 0.1) {
            
            HelperService.uploadToServer(data: imageData, name: itemNameTextField.text!, type: typeTextField.text!, size: sizeTextField.text!, description: descriptionTextView.text, onSuccess: {
                self.cleanUp()
                self.tabBarController?.selectedIndex = 0
            })
        }
        else {
            
            // Displays error message if no image has been selected
            ProgressHUD.showError("Please select an image")
        }

    }
    
    
    
    
    
    
    // Action performed when view is touched. Keyboard will hide
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //disables keyboard once view is touched
        view.endEditing(true)
    }
    
    
    
    
    
    func keyboardWillShow(_ notification: NSNotification) {
        
        // Get dimensions of the keyboard frame
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        // Animate the transition
        UIView.animate(withDuration: 0.2) {
//            self.bottomConstraint.constant = keyboardFrame!.height - 50
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    
    
    func keyboardWillHide(_ notification: NSNotification) {
        // Animate the transition
        UIView.animate(withDuration: 0.2) {
//            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}










extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did finish picking media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            photo.image = image
        }
        print(info)
        dismiss(animated: true, completion: nil)
    }
}
