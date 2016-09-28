//
//  MutabaahViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/22/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

extension DateFormatter {
    func defaultDateFormatter() -> DateFormatter {
        self.dateFormat = "yyyy-MM-dd"
        return self
    }
    
    func readableDateFormatter() -> DateFormatter {
        self.dateFormat = "d MMMM yyyy"
        return self
    }
}

class MutabaahViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ibadahLabel: UILabel!
    
    /* detail view */
    @IBOutlet weak var valueLabel: UILabel!
    
    var spinner = UIActivityIndicatorView()
    var spinner0 = UIActivityIndicatorView()
    let dateFormatter = DateFormatter().defaultDateFormatter()
    let readableDateFormatter = DateFormatter().readableDateFormatter()
    var currentDate: Date! = Date()
    var listOfIbadahs = NSMutableArray()
    
    
    @IBAction override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        tableView.register(UINib(nibName: "IbadahTableViewCell", bundle: nil), forCellReuseIdentifier: "ibadahCell")
        tableView.dataSource = self

        /* detail view */
        valueLabel.isHidden = true
        dateLabel.isHidden = true
        dateLabel.text = readableDateFormatter.string(from: currentDate)
        
        spinner = UIActivityIndicatorView(frame: CGRect(x: self.mainView.center.x, y: self.tableView.center.y - 50, width: 10, height: 10))
        spinner0 = UIActivityIndicatorView(frame: CGRect(x: self.mainView.center.x, y: self.detailView.center.y, width: 10, height: 10))
        spinner.activityIndicatorViewStyle = .gray
        spinner0.activityIndicatorViewStyle = .whiteLarge
        
        mainView.addSubview(spinner0)
        mainView.addSubview(spinner)
        
        /* start loading view */
        
        spinner0.startAnimating()
        spinner.startAnimating()
        
        APIClient.sharedClient.fetchListOfIbadahs {
            //print("fetched ibadahs")
            APIClient.sharedClient.getUserMutabaahs {
                //print("fetched mutabaahs")
                self.listOfIbadahs = APIClient.sharedClient.listOfIbadahs
                self.decodeMutabaahsForDate(self.currentDate)
                self.loadListOfIbadahs()
            }
        }
        
        tableView.isUserInteractionEnabled = false
    }
    
    func decodeMutabaahsForDate(_ date: Date) {
        var records: [[String: AnyObject]] = [[String:AnyObject]]()
        if let mutabaah = APIClient.sharedClient.rootResource["mutabaah"] as? [String:AnyObject] {
            if let currentMutabaah = mutabaah[dateFormatter.string(from: date)] as? [String:AnyObject] {
                if let currentRecords = currentMutabaah["records"] as? [[String:AnyObject]] {
                    records = currentRecords
                    //print(records)
                } else { print("1") }
            } else { print("2") }
        } else { print("3") }
        
        for record in records {
            for ibadah in listOfIbadahs {
                var _ibadah = ibadah as? [String:String]
                if (record["ibadah_id"] as! String == _ibadah!["_id"]!)  {
                    _ibadah!.updateValue(String(describing: record["value"]!), forKey: "value")
                    listOfIbadahs.replaceObject(at: listOfIbadahs.index(of: ibadah), with: _ibadah!)
                }
            }
        }
    }
    
    func loadListOfIbadahs() {
        spinner.stopAnimating()
        spinner0.stopAnimating()
        valueLabel.isHidden = false
        dateLabel.isHidden = false
        tableView.isUserInteractionEnabled = true
        
       // if let ibadah = listOfIbadahs.objectAtIndex(0) as? [String:String] {
            valueLabel.text = "Pilih!"
       // }
        tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
    }
    
    override func viewDidAppear(_ animated: Bool) {
       // mainView.insertSubview(detailView, aboveSubview: tableView)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfIbadahs.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ibadahCell", for: indexPath) as! IbadahTableViewCell
        
        let ibadah = listOfIbadahs.object(at: (indexPath as NSIndexPath).row) as? Dictionary<String, String>
        
        cell.ibadahTarget.text = ibadah!["target"]?.separate("_")
        cell.ibadahLabel.text = ibadah!["name"]?.separateAndCapitalize("_")
        
        if let value = ibadah!["value"] {
            cell.ibadahValue.text = value
        } else {
            cell.ibadahValue.text = "n/a"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        struct h { static var previousIndex = -1000 }
        let ibadah = listOfIbadahs.object(at: (indexPath as NSIndexPath).row) as? [String:String]
        
        if (indexPath as NSIndexPath).row != h.previousIndex {
            valueLabel.slideInFromBottom(0.5)
            ibadahLabel.slideInFromBottom(0.5)
            //valueLabel.text = ibadah!["name"]
            
            ibadahLabel.text = ibadah!["name"]?.separateAndCapitalize("_")
            
            if let value = ibadah!["value"] {
                if ibadah!["unit_name"] != nil {
                    valueLabel.text = value + " " + ibadah!["unit_name"]!
                } else {
                    valueLabel.text = value
                }
            } else {
                valueLabel.text = "No Record"
            }
        }
        
        h.previousIndex = (indexPath as NSIndexPath).row
    }

}
