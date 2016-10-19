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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBAction override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }

    @IBAction func backToMain() {
        self.performSegue(withIdentifier: "backToMain", sender: self)
    }
    
    func loadGroupInfo() {
        //groupLabel.isHidden = true
        
        //spinner.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 10.0, height: 10.0)
        //spinner.startAnimating()
        
        APIClient.sharedClient.getGroupInformation({ (group) in
            //self.groupLabel.text = (group["name"] as! String)
            //self.groupLabel.isHidden = false
            //self.spinner.stopAnimating()
        }) { (error) in
            if (error.code == Constants.Error.Code.userGroupNotExistError.rawValue) {
                //self.groupLabel.text = "You do not belong to any group."
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
    
    override func viewDidLoad() {
        loadGroupInfo()
    }
}

class GroupCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var groupLabel: UILabel!
}

class GroupCollectionViewController: UICollectionViewController, GridCollectionLayoutDelegate {

    var joinedGroupInfo: [Dictionary<String,AnyObject>] = []
    var joinedGroups: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = collectionView?.collectionViewLayout as? GridCollectionViewLayout {
            layout.delegate = self
        }
        
        joinedGroups = APIClient.sharedClient.rootResource["groups"] as! [String]
        
        if (joinedGroups.isEmpty) {
            collectionView?.isHidden = true
        } else {
            collectionView?.register(UINib(nibName: "GroupCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "groupColCell")
            collectionView?.delegate = self
                    
            for jg in joinedGroups {
                APIClient.sharedClient.getGroupForId(jg, success: { (groupInfo) in
                    self.joinedGroupInfo.append(groupInfo)
                    if (self.joinedGroupInfo.count == self.joinedGroups.count) {
                        //self.collectionView?.reloadItems(at: [IndexPath(item: i, section: 0)])
                        self.collectionView?.reloadData()
                    }
                }, failure: { (error) in
                        // do nothing
                })
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupColCell", for: indexPath) as! GroupCollectionViewCell
        
        if joinedGroupInfo.count > 0 {
            let groupInfo = joinedGroupInfo[indexPath.item]
            cell.backgroundColor = UIColor.clear //UIColor(red: 39.0/255.0, green: 174.0/255.0, blue: 96.0/255.0, alpha: 1.0)
            cell.groupLabel.text = groupInfo["name"] as! String?
            cell.groupLabel.isHidden = false
        } else {
            cell.backgroundColor = UIColor.clear
            cell.groupLabel.isHidden = true
        }
        
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.joinedGroups.count
    }
    
    // MARK:- GroupCollectionLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, heightForBoxAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        //let layout = self.collectionView?.collectionViewLayout as! GroupCollectionViewLayout
        return 135.0
       // return ((self.view.frame.size.height - (layout.cellPadding * 2))/CGFloat((joinedGroups.count/layout.numberOfColumns)+1))
    }
}

