//
//  ViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 6/18/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // email text, tint color, and placeholder text to white
        emailTextField.tintColor = UIColor.white
        emailTextField.textColor = UIColor.white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.7)])
        
        // password text, tint color, and placeholder text to white
        passwordTextField.textColor = UIColor.white
        passwordTextField.tintColor = UIColor.white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.7)])
        
        // creates email underline and applies it
        let bottomLayerEmail = CALayer()
        bottomLayerEmail.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.5)
        bottomLayerEmail.backgroundColor = UIColor(white: 1.0, alpha: 1).cgColor
        emailTextField.layer.addSublayer(bottomLayerEmail)
        
        // creates password underline and applies it
        let bottomLayerPassword = CALayer()
        bottomLayerPassword.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.5)
        bottomLayerPassword.backgroundColor = UIColor(white: 1.0, alpha: 1).cgColor
        passwordTextField.layer.addSublayer(bottomLayerPassword)
        
        // round out sign in button, which is initially disabled
        loginButton.isEnabled = false
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        loginButton.layer.borderColor = (UIColor.white).cgColor
        loginButton.layer.borderWidth = 2
        loginButton.clipsToBounds = true
        
        handleTextField()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //disables keyboard once view is touched
        view.endEditing(true)
    }
    
    // If user is already signed in, launches straight through authentication
    override func viewDidAppear(_ animated: Bool) {
        if API.User.CURRENT_USER != nil {
            self.performSegue(withIdentifier: "signInSegue", sender: nil)
        }
    }
    
    func handleTextField() {
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            loginButton.isEnabled = false
            return
        }
        
        loginButton.isEnabled = true
        
    }
    
    @IBAction func loginButton_TouchUpInside(_ sender: UIButton) {
        //disables keyboard once signin button is touched
        view.endEditing(true)
        
        //display sign in progress
        ProgressHUD.show("Signing in...", interaction: false)
        
        AuthService.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
            ProgressHUD.showSuccess("Success!")
            self.performSegue(withIdentifier: "signInSegue", sender: nil)
        }, onError: { error in
            ProgressHUD.showError(error!)
            print(error!)
        })
    }
    
}



