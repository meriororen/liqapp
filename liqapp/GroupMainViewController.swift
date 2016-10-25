//
//  GroupMainViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 10/5/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

class GroupMainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, GridCollectionLayoutDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }

    var selectedGroupId  = ""
    private var joinedGroupInfo: [Dictionary<String,AnyObject>] = []
    private var joinedGroups: [String] = []
    
    func loadGroupInfo() {
        APIClient.sharedClient.getGroupInformation({ (group) in
            self.collectionView.isUserInteractionEnabled = true
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
        super.viewDidLoad()
        
        loadGroupInfo()
        
        collectionView.register(UINib(nibName: "GroupCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "groupColCell")
        
        if let layout = collectionView.collectionViewLayout as? GridCollectionViewLayout {
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.joinedGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedGroupId = joinedGroups[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "groupDetailVC") as! GroupDetailViewController
        vc.groupId = joinedGroups[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        //performSegue(withIdentifier: "groupDetailSegue", sender: self)
    }
    
    // MARK:- GroupCollectionLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, heightForBoxAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        //let layout = self.collectionView?.collectionViewLayout as! GroupCollectionViewLayout
        return 135.0
        // return ((self.view.frame.size.height - (layout.cellPadding * 2))/CGFloat((joinedGroups.count/layout.numberOfColumns)+1))
    }
    
    func goBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

class GroupCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var groupLabel: UILabel!
}
