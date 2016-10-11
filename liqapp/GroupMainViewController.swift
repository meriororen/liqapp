//
//  GroupMainViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 10/5/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

class GroupMainViewController: UIViewController {
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction override func unwind(for segue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }

    @IBAction func backToMain() {
        self.performSegue(withIdentifier: "backToMain", sender: self)
    }
    
    override func viewDidLoad() {
        APIClient.sharedClient.getGroupInformation({ (group) in
                self.groupLabel.text = (group["name"] as! String)
            }) { (error) in
                if (error.code == Constants.Error.Code.userGroupNotExistError.rawValue) {
                    self.groupLabel.text = "You do not belong to any group."
                    let alert = UIAlertController(title: "Info", message: "You do not belong to any group. Please join a group.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style:
                        .default, handler: { (action) -> Void in
                            self.performSegue(withIdentifier: "toSearchGroup", sender: self)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
    
}
