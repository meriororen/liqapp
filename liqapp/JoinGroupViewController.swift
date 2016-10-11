//
//  JoinGroupViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 10/10/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

class JoinGroupViewController: UITableViewController, UISearchDisplayDelegate {
    
    var allGroups = [Dictionary<String,AnyObject>]()
    var filteredGroups = [Dictionary<String,AnyObject>]()
    var searchController: UISearchController! = nil
    
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView!.dequeueReusableCell(withIdentifier: "groupCell") as! JoinGroupTableViewCell
        
        var group = Dictionary<String,String>()
        
        if (searchController.isActive && searchController.searchBar.text != "" && filteredGroups.count > 0) {
            group = filteredGroups[indexPath.row] as! Dictionary<String,String>
        } else {
            group = allGroups[indexPath.row] as! Dictionary<String,String>
        }
        
        if group["name"] != nil && group["_id"] != nil {
            cell.groupName.text = group["name"]
            cell.groupId = group["_id"]!
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
