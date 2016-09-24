//
//  loginViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/19/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import QuartzCore
import UIKit
import Foundation

class LoginViewController : UIViewController, NSURLSessionDataDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    var spinner = UIActivityIndicatorView()
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 70, 70))
        spinner.activityIndicatorViewStyle = .Gray
        spinner.center = self.loginButton.center
        loginButton.addSubview(spinner)
        spinner.startAnimating()
        
        authenticate()
    }
    
    override func loadView() {
        super.loadView();
        
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
    }
    
    func authenticate() {
        var params = Dictionary<String, AnyObject>()
        params.updateValue("\(usernameTextField.text!)", forKey: "username")
        params.updateValue("\(passwordTextField.text!)", forKey: "password")

        AuthManager.sharedManager.authenticateWithCode(params, success: {
            dispatch_async(dispatch_get_main_queue(), {            
                let storyboard = UIStoryboard(name: "Main", bundle:nil)
                let mutabaahViewController = storyboard.instantiateViewControllerWithIdentifier("mainVCIdentifier")
                
                self.spinner.stopAnimating()
                
                self.presentViewController(mutabaahViewController, animated: true, completion: nil)
            })
        }, failure: { (error) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugLabel.text = "Failed"
                }
    
            }
        )
    }
}