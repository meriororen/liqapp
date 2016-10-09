//
//  MainViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/25/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit
import RealmSwift

class mainItemButton: UIButton {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor(red: 11.0/255.0, green: 102.0/255.0, blue: 255.0/255.0, alpha: 0.5).cgColor
        self.layer.borderWidth = 2.0
    }
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var mutabaahButton: mainItemButton!
    @IBOutlet weak var TBDButton: mainItemButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var spinnerLabel: UILabel!
    
    override func viewDidLoad() {
        welcomeLabel.isHidden = true
        contactImage.isHidden = true
        contactImage.image?.withRenderingMode(.alwaysTemplate)
        contactImage.tintColor = UIColor.darkGray
        
        spinner.startAnimating()
        spinnerLabel.text = "Loading..."
        
        if APIClient.sharedClient.rootResource.count > 0 {
            userReady()
        } else {
            APIClient.sharedClient.updateUserBasicInfo {
                self.userReady()
            }
        }
    }
    
    func userReady() {
        self.welcomeLabel.text = (APIClient.sharedClient.rootResource["name"] as! String)
        self.welcomeLabel.isHidden = false
        self.contactImage.isHidden = false
        self.spinnerLabel.isHidden = true
        self.spinner.stopAnimating()
    }
    
    @IBAction func logoutUser() {
        APIClient.sharedClient.logoutThenDeleteAllStoredData()
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notif.kLoginViewControllerShowLoggedOutSessionExpired), object: self)
    }
}
