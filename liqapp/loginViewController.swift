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
    
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        authenticate()
    }
    
    let getTokenMethod = "api/auth"
    let baseURLSecureString = "http://liqo.herokuapp.com/"
    var requestToken: String?
    
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
                let mutabaahTableViewController = storyboard.instantiateViewControllerWithIdentifier("mutabaahTVIdentifier") as! MutabaahTableViewController
                
                self.presentViewController(mutabaahTableViewController, animated: true, completion: nil)
            })
        }, failure: { (error) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugLabel.text = "Failed"
                }
    
            }
        )
    }
    
    func login() {
        let username: String = usernameTextField.text!
        let password: String = passwordTextField.text!
        let post: String = "username=\(username)&password=\(password)"
        let postData: NSData = post.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!
        let urlString = baseURLSecureString + getTokenMethod
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue(Constants.HTTPHeaderValues.urlencoded, forHTTPHeaderField: Constants.HTTPHeaderKeys.contentType)
        request.HTTPBody = postData
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, loginError in
            if let error = loginError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.debugLabel.text = "Login Connection Error. "
                }
                print("Could not complete the request \(error)")
            } else {
                let res = response as! NSHTTPURLResponse
                let resHeader = res.allHeaderFields as! Dictionary<String, String>
                
                //print(resHeader)
                                
                if (res.statusCode >= 200 && res.statusCode <= 300) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugLabel.text = "Login success."
                    APIClient.sharedClient.updateAuthorizationHeader(resHeader["Authorization"]!)
                        
                        let listOfIbadahs = APIClient.sharedClient.fetchListOfIbadahs()
                        
                        let storyboard = UIStoryboard(name: "Main", bundle:nil)
                        let mutabaahTableViewController = storyboard.instantiateViewControllerWithIdentifier("mutabaahTVIdentifier") as! MutabaahTableViewController
                        
                        mutabaahTableViewController.listOfIbadahs = listOfIbadahs
                        
                        self.presentViewController(mutabaahTableViewController, animated: true, completion: nil)
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