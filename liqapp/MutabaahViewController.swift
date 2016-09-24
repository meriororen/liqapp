//
//  MutabaahViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/22/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

extension UIView {
    func slideInFromBottom(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let slideInFromBottomTransition = CATransition()
        
        if let delegate: AnyObject = completionDelegate {
            slideInFromBottomTransition.delegate = delegate
        }
        
        slideInFromBottomTransition.type = kCATransitionPush
        slideInFromBottomTransition.subtype = kCATransitionFromBottom
        slideInFromBottomTransition.duration = duration
        slideInFromBottomTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideInFromBottomTransition.fillMode = kCAFillModeRemoved
        
        self.layer.addAnimation(slideInFromBottomTransition, forKey: "slideInFromBottomTransition")
    }
}


class MutabaahViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    /* detail view */
    @IBOutlet weak var valueLabel: UILabel!
    
    var spinner = UIActivityIndicatorView()
    var spinner0 = UIActivityIndicatorView()
    
    var listOfIbadahs: NSArray!
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        tableView.registerNib(UINib(nibName: "IbadahTableViewCell", bundle: nil), forCellReuseIdentifier: "ibadahCell")
        tableView.dataSource = self

        /* detail view */
        valueLabel.hidden = true
        
        spinner = UIActivityIndicatorView(frame: CGRectMake(self.mainView.center.x, self.tableView.center.y - 50, 10, 10))
        spinner0 = UIActivityIndicatorView(frame: CGRectMake(self.mainView.center.x, self.detailView.center.y, 10, 10))
        spinner.activityIndicatorViewStyle = .Gray
        spinner0.activityIndicatorViewStyle = .WhiteLarge
        
        
        mainView.addSubview(spinner0)
        mainView.addSubview(spinner)
        
        /* start loading view */
        
        spinner0.startAnimating()
        spinner.startAnimating()
        
        APIClient.sharedClient.updateUserResources {
            self.loadListOfIbadahs()
        }
        
        tableView.userInteractionEnabled = false
    }
    
    func loadListOfIbadahs() {
        spinner.stopAnimating()
        spinner0.stopAnimating()
        valueLabel.hidden = false
        tableView.userInteractionEnabled = true
        
        if let ibadah = APIClient.sharedClient.listOfIbadahs.objectAtIndex(0) as? [String:String] {
            valueLabel.text = ibadah["name"]
        }
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ibadahCell", forIndexPath: indexPath) as! IbadahTableViewCell
        
        let ibadah = APIClient.sharedClient.listOfIbadahs.objectAtIndex(indexPath.row) as? Dictionary<String, String>
        
        cell.ibadahLabel.text = ibadah!["name"]
        cell.ibadahValue.text = String(indexPath.row * 2)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        struct h { static var previousIndex = 0 }
        //let ibadah = APIClient.sharedClient.listOfIbadahs.objectAtIndex(indexPath.row) as? [String:String]
        
        if indexPath.row != h.previousIndex {
            valueLabel.slideInFromBottom(0.5)
            //valueLabel.text = ibadah!["name"]
            valueLabel.text = String(indexPath.row * 2) + " rakaat"
        }
        
        h.previousIndex = indexPath.row
    }

}
