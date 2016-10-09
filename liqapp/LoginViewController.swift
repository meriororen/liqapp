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
import RealmSwift

struct Notif {
    static let kLoginViewControllerShowLoginFailed = "showLoginViewControllerLoginFailed"
    static let kLoginViewControllerShowLoggedOutSessionExpired = "showLoginViewControllerLoggedOutSessionExpired"
}

class LoginViewController : UIViewController, URLSessionDataDelegate, UINavigationBarDelegate {
    @IBOutlet weak var usernameTextField: UIAuthTextField!
    @IBOutlet weak var passwordTextField: UIAuthTextField!
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
            
            usernameTextField.authState = .authError
            passwordTextField.authState = .authError
            
            let error: APIError = (notification.userInfo as! [String:APIError])["error"]!
            let alert = error.alert
            if error.code == Constants.Error.Code.unauthorizedError.rawValue {
                alert!.message = "Invalid Username or Password"
            } else {
                alert!.message = "Connection Error"
            }
            /*
            let alert = UIAlertController(title: "Error", message: "Invalid Username or Password", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            */
            self.present(alert!, animated: true, completion: nil)
        }
    }
    
    func authenticate() {
        var params = Dictionary<String, AnyObject>()
        params.updateValue("\(usernameTextField.text!)" as AnyObject, forKey: "username")
        params.updateValue("\(passwordTextField.text!)" as AnyObject, forKey: "password")
        
        AuthManager.sharedManager.authenticateWithCode(params, success: {
            DispatchQueue.main.async(execute: {
                /* present main view */
                
                let storyboard = UIStoryboard(name: "Main", bundle:nil)
                let mainViewController = storyboard.instantiateViewController(withIdentifier: "mainVCIdentifier")
                self.spinner.stopAnimating()
                self.present(mainViewController, animated: true, completion: nil)
            })
            }, failure: { (error) in
                NotificationCenter.default.post(NSNotification(name: NSNotification.Name(rawValue: Notif.kLoginViewControllerShowLoginFailed), object:nil, userInfo:["error":error]) as Notification)
        })
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
