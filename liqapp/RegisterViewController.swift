//
//  RegisterViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 10/3/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UIAuthTextField!
    @IBOutlet weak var passwordTextField: UIAuthTextField!
    @IBOutlet weak var emailTextField: UIAuthTextField!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction override func unwind(for segue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        //
    }
    
    @IBAction func cancelPressed(_ sender: AnyObject?) {
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
    @IBAction func registerPressed(_ sender: AnyObject?) {
        if (usernameTextField.text == "" || passwordTextField.text == ""
            || emailTextField.text == "") { return }
        
        var params = Dictionary<String, AnyObject>()
        params.updateValue("\(usernameTextField.text!)" as AnyObject, forKey: "username")
        params.updateValue("\(passwordTextField.text!)" as AnyObject, forKey: "password")
        
        APIClient.sharedClient.registerUser(params, success: {
                self.performSegue(withIdentifier: "unwindToLogin", sender: self)
            }, failure: { (error) in
                DispatchQueue.main.async(execute: {
                    if let alert = error.alert {
                        self.present(alert, animated: true, completion: nil)
                    }
                })
        })
    }
}
