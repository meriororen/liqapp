//
//  MutabaahViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/22/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

class MutabaahViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    /* detail view */
    @IBOutlet weak var valueLabel: UILabel!
    
    var spinner = UIActivityIndicatorView()
    var listOfIbadahs: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        
        /*
        if (APIClient.sharedClient.listOfIbadahs as NSMutableArray!) != nil {
            listOfIbadahs = APIClient.sharedClient.listOfIbadahs
        } else {
            listOfIbadahs = NSArray()
        }
        */
        
        /* detail view */
        valueLabel.center.x = detailView.center.x
        
        spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 70, 70))
        spinner.activityIndicatorViewStyle = .Gray
        spinner.center = self.tableView.center
        mainView.addSubview(spinner)
        spinner.startAnimating()
        
        APIClient.sharedClient.fetchListOfIbadahs {
            self.loadListOfIbadahs()
        }
        
        //tableView = mainView.frame.height - detailView.frame.height
    }
    
    func loadListOfIbadahs() {
        self.spinner.stopAnimating()
        if let ibadah = APIClient.sharedClient.listOfIbadahs.objectAtIndex(0) as? [String:String] {
            self.valueLabel.text = ibadah["name"]
        }
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    override func viewDidAppear(animated: Bool) {
        mainView.insertSubview(detailView, aboveSubview: tableView)
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APIClient.sharedClient.listOfIbadahs.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ibadahCell", forIndexPath: indexPath)
        
        let ibadah = APIClient.sharedClient.listOfIbadahs.objectAtIndex(indexPath.row) as? Dictionary<String, String>
        
        cell.textLabel?.text = ibadah!["name"]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let ibadah = APIClient.sharedClient.listOfIbadahs.objectAtIndex(indexPath.row) as? [String:String]
        self.valueLabel.text = ibadah!["name"]
    }

}
