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
    static let kLoginViewControllerShowLoginFailed = "showLoginViewControllerLoginFailed"
    static let kLoginViewControllerShowLoggedOutSessionExpired = "showLoginViewControllerLoggedOutSessionExpired"
}

class loginTextField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width, height: bounds.height)
    }
}

class LoginViewController : UIViewController, URLSessionDataDelegate, UINavigationBarDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    var spinner = UIActivityIndicatorView()
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if (usernameTextField.text == "" || passwordTextField.text == "") { return }
        
        spinner = UIActivityIndicatorView(frame: CGRect(x: self.loginButton.center.x, y: self.loginButton.center.y, width: 70, height: 70))
        spinner.activityIndicatorViewStyle = .gray
        spinner.center = self.loginButton.center
        view.addSubview(spinner)
        
        self.loginButton.adjustsImageWhenDisabled = true
        self.loginButton.isEnabled = false
        self.loginButton.alpha = 0.25
        
        spinner.startAnimating()
        
        authenticate()
    }
    
    override func viewDidLoad() {
        usernameTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderWidth = 1.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.popToSelf), name: NSNotification.Name(rawValue: Notif.kLoginViewControllerShowLoginFailed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.popToSelf), name: NSNotification.Name(rawValue: Notif.kLoginViewControllerShowLoggedOutSessionExpired), object: nil)
    }
    
    override func loadView() {
        super.loadView();
        
        loginButton.clipsToBounds = true
    }
    
    func popToSelf(notification: NSNotification) {
        if (notification.name.rawValue == Notif.kLoginViewControllerShowLoginFailed) {
            spinner.stopAnimating()
            loginButton.alpha = 1.0
            loginButton.isEnabled = true
            usernameTextField.layer.borderColor = UIColor.red.cgColor
            passwordTextField.layer.borderColor = UIColor.red.cgColor
            
            let errorBgColor = UIColor(red: 203.0/255.0, green: 171.0/255.0, blue: 175.0/255.0, alpha: 0.5).cgColor
            usernameTextField.layer.backgroundColor = errorBgColor
            passwordTextField.layer.backgroundColor = errorBgColor
            print("login failed!")
        }
    }
    
    func authenticate() {
        var params = Dictionary<String, AnyObject>()
        params.updateValue("\(usernameTextField.text!)" as AnyObject, forKey: "username")
        params.updateValue("\(passwordTextField.text!)" as AnyObject, forKey: "password")
        
        AuthManager.sharedManager.authenticateWithCode(params, success: {
            DispatchQueue.main.async(execute: {
                let storyboard = UIStoryboard(name: "Main", bundle:nil)
                let mutabaahViewController = storyboard.instantiateViewController(withIdentifier: "mainVCIdentifier")
                
                self.spinner.stopAnimating()
                
                self.present(mutabaahViewController, animated: true, completion: nil)
            })
            }, failure: { (error) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notif.kLoginViewControllerShowLoginFailed), object: self)
        })
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
