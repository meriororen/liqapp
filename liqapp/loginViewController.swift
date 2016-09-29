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

class LoginViewController : UIViewController, URLSessionDataDelegate, UINavigationBarDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    var spinner = UIActivityIndicatorView()
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
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
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.popToSelf), name: NSNotification.Name(rawValue: Notif.kLoginViewControllerShow), object: nil)
    }
    
    override func loadView() {
        super.loadView();
        
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
    }
    
    func popToSelf() {
        self.present(self, animated: true, completion: nil)
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
                DispatchQueue.main.async {
                    self.debugLabel.text = "Failed"
                }
    
            }
        )
    }
        
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
