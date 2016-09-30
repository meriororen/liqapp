//
//  MutabaahViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/22/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit
import RealmSwift

class MutabaahViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ibadahLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var controlView: UIView!
    
    /* detail view */
    @IBOutlet weak var valueLabel: UILabel!
    
    var spinner = UIActivityIndicatorView()
    var spinner0 = UIActivityIndicatorView()
    let dateFormatter = DateFormatter().defaultDateFormatter()
    let readableDateFormatter = DateFormatter().readableDateFormatter()
    var currentDate: NSDate! = NSDate()
    var listOfIbadahs = NSMutableArray()
    var selectedIndex = -1000
    var selectedIndexPath: IndexPath!
    
    @IBAction override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }
    
    @IBAction func plusButtonPressed() {
        if selectedIndex >= 0 {
            var ibadah = (listOfIbadahs.object(at: selectedIndex) as? [String:AnyObject])!
            let fillnumber_type = (ibadah["type"] as! String) == "fillnumber"
            let record = ibadah["record"] as? Record
            var value = { () -> Int in 
                if record != nil { return record!.value }
                else { return 0 }
            }()
            
            if record != nil && fillnumber_type {
                value = value + 1
            } else {
                value = 1
            }
            
            ibadah.updateValue(record!, forKey: "record")
            listOfIbadahs.replaceObject(at: selectedIndex, with: ibadah)
            updateValueLabel(ibadah: ibadah)
        }
    }
    
    @IBAction func minusButtonPressed() {
        if selectedIndex >= 0 {
            var ibadah = (listOfIbadahs.object(at: selectedIndex) as? [String:AnyObject])!
            let fillnumber_type = (ibadah["type"] as! String) == "fillnumber"
            let value = ibadah["value"] as? Int
            if value != nil && fillnumber_type && value != 0 {
                ibadah.updateValue((value! - 1) as AnyObject, forKey: "value")
            } else {
                ibadah.updateValue(0 as AnyObject, forKey: "value")
            }
            listOfIbadahs.replaceObject(at: selectedIndex, with: ibadah)
            updateValueLabel(ibadah: ibadah)
        }
    }
    
    func updateValueLabel(ibadah: [String:AnyObject]) {
        let type = (ibadah["type"] as! String) == "fillnumber"
        let value = ibadah["value"] as? Int
        if ibadah["unit_name"] != nil {
            valueLabel.text = String(describing: ibadah["value"]!) + " " + (ibadah["unit_name"]! as! String)
        } else {
            if (type) {
                valueLabel.text = String(describing: ibadah["value"]!)
            } else {
                valueLabel.text = (value == 0) ? "no" : "yes"
            }
        }
        
        tableView.reloadRows(at: [selectedIndexPath as IndexPath], with: .none)
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
        ibadahLabel.isHidden = true
        dateLabel.text = readableDateFormatter.string(from: currentDate as Date)
        
        /* control view */
        controlView.isHidden = true
        
        spinner = UIActivityIndicatorView(frame: CGRect(x: self.mainView.center.x, y: self.tableView.center.y - 50, width: 10, height: 10))
        spinner0 = UIActivityIndicatorView(frame: CGRect(x: self.mainView.center.x, y: self.detailView.center.y, width: 10, height: 10))
        spinner.activityIndicatorViewStyle = .gray
        spinner0.activityIndicatorViewStyle = .whiteLarge
        
        mainView.addSubview(spinner0)
        mainView.addSubview(spinner)
        
        /* start loading view */
        
        spinner0.startAnimating()
        spinner.startAnimating()
        
        APIClient.sharedClient.getListOfIbadahs {
            //print("fetched ibadahs")
            APIClient.sharedClient.getUserMutabaahs {
               // print("fetched mutabaahs")
                self.listOfIbadahs = APIClient.sharedClient.listOfIbadahs
                self.decodeMutabaahsForDate(date: self.currentDate)
                self.loadListOfIbadahs()
            }
        }
        
        tableView.isUserInteractionEnabled = false
    }
    
    func decodeMutabaahsForDate(date: NSDate) {
        //let ds = dateFormatter.string(from: date as Date)
        let ds = "2016-09-28"
        var records: List<Record>? = nil
        
        if let realm = APIClient.sharedClient.realm {
            let queryfilter = NSPredicate(format: "date = '%@'", ds)
            print(queryfilter.predicateFormat)
            let mutabaah: Mutabaah? = realm.objects(Mutabaah.self).filter(queryfilter).first
            records = mutabaah?.records
            print(records)
        }
     
        if records != nil {
            for i in 0..<(records?.count)! - 1 {
                if let record = records?[i] {
                    for ibadah in listOfIbadahs {
                        var _ibadah = ibadah as? [String:AnyObject]
                        if (record["ibadah_id"] as! String == _ibadah!["_id"]! as! String)  {
                            //_ibadah!.updateValue(record["value"]! as AnyObject, forKey: "value")
                            _ibadah!.updateValue(record as AnyObject, forKey: "record")
                            listOfIbadahs.replaceObject(at: listOfIbadahs.index(of: ibadah), with:  _ibadah!)
                        }
                    }
                }
            }
        }
    }
    
    
    func loadListOfIbadahs() {
        spinner.stopAnimating()
        spinner0.stopAnimating()
        valueLabel.isHidden = false
        dateLabel.isHidden = false
        ibadahLabel.isHidden = false
        
        controlView.slideInFromBottom(0.5)
        controlView.isHidden = false
        
        tableView.isUserInteractionEnabled = true
        
        valueLabel.text = "Pilih!"
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .fade)
    }
    
    override func viewDidAppear(_ animated: Bool) {
       // mainView.insertSubview(detailView, aboveSubview: tableView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        selectedIndex = -1000
    }
    
    // MARK: - Table view data source
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfIbadahs.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ibadahCell", for: indexPath as IndexPath) as! IbadahTableViewCell
        
        if let ibadah = listOfIbadahs.object(at: indexPath.row) as? Dictionary<String, AnyObject> {
            cell.ibadahTarget.text = (ibadah["target"] as! String).separate("_")
            cell.ibadahLabel.text = (ibadah["name"] as! String).separateAndCapitalize("_")
            let fillnum_type = (ibadah["type"] as! String) == "fillnumber"
            
            if let record = ibadah["record"] as? Record {
                if (fillnum_type) {
                    cell.ibadahValue.text = String(describing: record.value)
                } else {
                    cell.ibadahValue.text = record.value == 0 ? "no" : "yes"
                }
            } else {
                if fillnum_type {
                    cell.ibadahValue.text = "0"
                } else {
                    cell.ibadahValue.text = "no"
                }
            }
        }
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let ibadah = listOfIbadahs.object(at: indexPath.row) as? [String:AnyObject] {
            if indexPath.row != selectedIndex {
                valueLabel.slideInFromBottom(0.5)
                ibadahLabel.slideInFromBottom(0.5)
                //valueLabel.text = ibadah!["name"]
            
                ibadahLabel.text = (ibadah["name"] as! String).separateAndCapitalize("_")
                
                if (ibadah["type"] as! String == "yesno") {
                    plusButton.setTitle("yes", for: .normal)
                    minusButton.setTitle("no", for: .normal)
                } else {
                    plusButton.setTitle("+1", for: .normal)
                    minusButton.setTitle("-1", for: .normal)
                }
            
                if let value = ibadah["value"] {
                    if ibadah["unit_name"] != nil {
                        valueLabel.text = String(describing: value) + " " + (ibadah["unit_name"] as! String)
                    } else {
                        valueLabel.text = String(describing: value)
                    }
                } else {
                    valueLabel.text = "Not Yet"
                }
            }
        }
        selectedIndex = indexPath.row
        selectedIndexPath = indexPath
    }

}
