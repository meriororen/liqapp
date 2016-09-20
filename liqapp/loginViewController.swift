//
//  loginViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/19/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import QuartzCore
import UIKit

class loginViewController : UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        getAuthToken()
    }
    
    let getTokenMethod = "api/auth"
    let baseURLSecureString = "http://liqo.herokuapp.com/"
    var requestToken: String?
    
    override func loadView() {
        super.loadView();
        
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
    }
    
    func getAuthToken() {
        let username: String = usernameTextField.text!
        let password: String = passwordTextField.text!
        let post: String = "username=\(username)&password=\(password)"
        let postData: NSData = post.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
        let urlString = baseURLSecureString + getTokenMethod
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = postData
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, loginError in
            if let error = loginError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugLabel.text = "Login Connection Error. "
                }
                print("Could not complete the request \(error)")
            } else {
                #if FALSE
                let parsedResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                #endif
                
                let res = response as! NSHTTPURLResponse!
                
                print(res.allHeaderFields)
                
                if (res.statusCode >= 200 && res.statusCode <= 300) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugLabel.text = "Login success."
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugLabel.text = "Login Failed. Status\(res.statusCode)"
                    }
                }
                
            }
        }
        task.resume()
    }
}