//
//  JoinGroupViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 10/10/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

class JoinGroupViewController: UIViewController, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var joinView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var allGroups = [Dictionary<String,AnyObject>]()
    var filteredGroups = [Dictionary<String,AnyObject>]()
    var searchController: UISearchController! = nil
    

    @IBAction override func unwind(for unwindSegue:UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        let mainGroupVC = (subsequentVC as! UINavigationController).viewControllers[1] as! GroupMainViewController
        mainGroupVC.loadGroupInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        tableView.register(UINib(nibName: "JoinGroupTableViewCell", bundle: nil), forCellReuseIdentifier: "groupCell")
        tableView.dataSource = self
        
        APIClient.sharedClient.getAllGroups({ (allGroups) in
                self.allGroups = allGroups
                self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.automatic)
            }) { (error) in
                // error
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView!.dequeueReusableCell(withIdentifier: "groupCell") as! JoinGroupTableViewCell
        
        var group = Dictionary<String,String>()
        
        if (searchController.isActive && searchController.searchBar.text != "" && filteredGroups.count > 0) {
            group = filteredGroups[indexPath.row] as! Dictionary<String,String>
        } else {
            group = allGroups[indexPath.row] as! Dictionary<String,String>
        }
        
        if group["name"] != nil && group["_id"] != nil {
            let joinedGroups = APIClient.sharedClient.rootResource["groups"] as! [String]
            for jg in joinedGroups {
                if (jg == group["_id"]!) {
                    cell.groupJoinRequest.isEnabled = false
                    cell.groupJoinRequest.setTitle("Joined", for: UIControlState.disabled)
                }
            }
            cell.groupName.text = group["name"]
            cell.groupId = group["_id"]!
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredGroups.count
        } else {
            return allGroups.count
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredGroups = allGroups.filter({ (group) -> Bool in
            let groupName = group["name"] as! String
            return groupName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
}

extension JoinGroupViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
