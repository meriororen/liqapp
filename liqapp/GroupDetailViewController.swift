//
//  GroupDetailViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 10/21/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit
import RealmSwift

class GroupDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var groupId = ""
    var dataOk = false
    var realm: Realm = APIClient.sharedClient.realm!
    
    var members = [Dictionary<String,AnyObject>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataOk = false
        
        APIClient.sharedClient.getGroupMembers(for: groupId, success: { (jsonData) in
            self.members = jsonData["response"] as! [Dictionary<String,AnyObject>]
            self.dataOk = true
            self.tableView.reloadData()
            self.getUserInfo()
        }) { (error) in
            // TODO: error handling
            print("error")
        }
    }
    
    func getUserInfo() {
        for mi in 0..<self.members.count {
            let m = self.members[mi]
            var user: User? = self.realm.object(ofType: User.self, forPrimaryKey: m["user_id"] as! String)
            if user == nil {
                APIClient.sharedClient.getUserInformation(for: m["user_id"] as! String, success: { (userData) in
                    try! self.realm.write {
                         user = self.realm.create(User.self, value: ["_id": userData["_id"] as! String, "name": userData["username"] as! String], update: true)
                    }
                    let indexPath = IndexPath(row: mi, section: 0)
                    print(String(format: "id: %@, name: %@, row: %d", m["user_id"] as! String, (user?.name)!, mi))
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                    }, failure: { (error) in
                        // TODO:
                        print("what!")
                })
            } else {
                let indexPath = IndexPath(row: mi, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataOk ? members.count : 5
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Members"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell")!
        
        if (dataOk) {
            let id = members[indexPath.row]["user_id"] as! String
            let user: User? = self.realm.object(ofType: User.self, forPrimaryKey: id)
            if user != nil {
                cell.textLabel?.text = user!.name
            } else {
                cell.textLabel?.text = id
            }
        }
        
        return cell
    }
    
    func goBack() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}
