//
//  MainViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/25/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var mutabaahButton: UIButton!
    @IBOutlet weak var TBDButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        mutabaahButton.layer.cornerRadius = 10
        TBDButton.layer.cornerRadius = 10
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
