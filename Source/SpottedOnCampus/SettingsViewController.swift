//
//  SettingsViewController.swift
//  SpottedOnCampus
//
//  Created by Antonio DelVecchio on 6/29/17.
//  Copyright © 2017 Antonio DelVecchio. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signout_TouchUpInside(_ sender: UIButton) {
        
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
