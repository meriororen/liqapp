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

struct Notif {
    static let kLoginViewControllerShow = "showLoginViewController"
}

class LoginViewController : UIViewController, NSURLSessionDataDelegate, UINavigationBarDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    var spinner = UIActivityIndicatorView()
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        spinner = UIActivityIndicatorView(frame: CGRectMake(self.loginButton.center.x, self.loginButton.center.y, 70, 70))
        spinner.activityIndicatorViewStyle = .Gray
        spinner.center = self.loginButton.center
        view.addSubview(spinner)
        self.loginButton.adjustsImageWhenDisabled = true
        self.loginButton.enabled = false
        self.loginButton.alpha = 0.25
        spinner.startAnimating()
        
        authenticate()
    }
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.popToSelf), name: Notif.kLoginViewControllerShow, object: nil)
    }
    
    override func loadView() {
        super.loadView();
        
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
    }
    
    func popToSelf() {
        self.presentViewController(self, animated: true, completion: nil)
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
        
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}