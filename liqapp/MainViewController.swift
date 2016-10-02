//
//  MainViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/25/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        welcomeLabel.isHidden = true
        
        APIClient.sharedClient.updateUserBasicInfo {
            self.welcomeLabel.text = "Welcome, " + (APIClient.sharedClient.rootResource["name"] as! String) + "!"
            self.welcomeLabel.isHidden = false
        }
    }
    
    @IBAction func logoutUser() {
        APIClient.sharedClient.logoutThenDeleteAllStoredData()
    }
}

class LaunchScreenViewController: UIViewController {
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    override func viewDidLoad() {
        spinner.startAnimating()
    }
}
