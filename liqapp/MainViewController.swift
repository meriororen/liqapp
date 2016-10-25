//
//  MainViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/25/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit
import RealmSwift
import FontAwesome_swift

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, GridCollectionLayoutDelegate, JoinGroupViewControllerDelegate {

    @IBOutlet weak var mutabaahButton: ItemButton!
    @IBOutlet weak var groupButton: ItemButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var spinnerLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var realm = APIClient.sharedClient.realm
    
    var mainMenu = [
        ["name": "Mutabaah", "icon" : FontAwesome.CalendarCheckO,
         "enabled": "yes", "segue": "mutabaahSegueId"],
        ["name": "Group", "icon": FontAwesome.Group,
         "enabled": "yes", "segue": "groupMainSegueId"],
        ["name": "Calendar", "icon" : FontAwesome.Calendar, "enabled": "no"],
        ["name": "Messages", "icon": FontAwesome.Envelope, "enabled": "no"],
        ["name": "Search", "icon" : FontAwesome.Search, "enabled": "yes", "segue": "toSearchGroupFromMain"],
        ["name": "News", "icon": FontAwesome.NewspaperO, "enabled": "no"],
            ["name": "Ask Help", "icon" : FontAwesome.Question, "enabled" : "no"],
        ["name": "Chat", "icon": FontAwesome.Commenting, "enabled": "no"],
        ["name": "Settings", "icon" : FontAwesome.Cog, "enabled": "no"],
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "MainMenuCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "mainMenuCell")
        
        if let layout = collectionView?.collectionViewLayout as? GridCollectionViewLayout {
            layout.delegate = self
        }
        
        collectionView.isUserInteractionEnabled = false
        
        contactImage.image?.withRenderingMode(.alwaysTemplate)
        contactImage.tintColor = UIColor.white
        
        welcomeLabel.isHidden = true
        contactImage.isHidden = true
        
        spinner.startAnimating()
        spinnerLabel.text = "Loading..."
        
        if APIClient.sharedClient.rootResource.count > 0 {
            userReady()
        } else {
            APIClient.sharedClient.updateUserBasicInfo(success: {
                self.userReady()
            }, failure: { (error) in
                if (error.code == Constants.Error.Code.userGroupNotExistError.rawValue) {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "joinGroupViewId") as! JoinGroupViewController
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }
    }
    
    internal func preparePopView() {
        APIClient.sharedClient.updateUserBasicInfo(success: {
            self.userReady()
            }, failure: { (error) in
            // TODO: error handling!
                print("failed!")
        })
    }
    
    func userReady() {
        self.welcomeLabel.text = (APIClient.sharedClient.rootResource["username"] as! String)
        self.welcomeLabel.isHidden = false
        self.contactImage.isHidden = false
        self.spinnerLabel.isHidden = true
        
        collectionView.isUserInteractionEnabled = true
        
        self.spinner.stopAnimating()
    }
    
    @IBAction func logoutUser() {
        APIClient.sharedClient.logoutThenDeleteAllStoredData()
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notif.kLoginViewControllerShowLoggedOutSessionExpired), object: self)
    }
    
    // MARK:- UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainMenu.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainMenuCell", for: indexPath) as!
        MainMenuCollectionViewCell
       
        let menuItem = mainMenu[indexPath.row] as [String:AnyObject]
        
        cell.backgroundColor = UIColor.blue
        cell.mainMenuButton.FAIconLabel.text = String.fontAwesomeIconWithName(menuItem["icon"] as! FontAwesome)
        cell.mainMenuButton.ItemLabel.text = menuItem["name"] as? String
        
        if(menuItem["enabled"] as! String == "no") { cell.mainMenuButton.isEnabled = false }
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let segueId = mainMenu[indexPath.row]["segue"] as? String {
            self.performSegue(withIdentifier: segueId, sender: self)
        }
    }
    
    // MARK:- GridCollectionLayoutDelegate
    func collectionView(_ collectionView: UICollectionView, heightForBoxAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        return 100.0
    }
}

class MainMenuCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainMenuButton: ItemButton!
}
