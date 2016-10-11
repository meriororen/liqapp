//
//  JoinGroupTableViewCell.swift
//  liqapp
//
//  Created by Isa Ansharullah on 10/10/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

class JoinGroupTableViewCell: UITableViewCell {
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var groupJoinRequest: UIButton!
    
    var groupId = ""
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    @IBAction func groupJoinRequestPressed(sender: AnyObject?) {
        groupJoinRequest.isHidden = true
        spinner.frame = CGRect(x: groupJoinRequest.center.x, y: groupJoinRequest.center.y, width: 5.0, height: 5.0)
        spinner.startAnimating()
        
        APIClient.sharedClient.requestJoinGroup(groupId, success: { 
            self.spinner.stopAnimating()
            self.spinner.isHidden = true
            self.groupJoinRequest.text = "Joined"
            self.groupJoinRequest.isHidden = false
        }, failure: { (error) in
            print("NO!")
        })
    }
}
