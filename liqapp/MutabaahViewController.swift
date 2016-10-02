//
//  MutabaahViewController.swift
//  liqapp
//
//  Created by Isa Ansharullah on 9/22/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit
import RealmSwift
import QuartzCore

extension UIButton {
    var text: String? {
        get {
            return self.currentTitle
        }
        set(new) {
            self.setTitle(new, for: .normal)
        }
    }
}


class MutabaahViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateButton: UIButton!
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
    var listOfIbadahs = [Ibadah]()
    var currentMutabaah = Mutabaah()
    var selectedIndex = -1000
    var selectedIndexPath: IndexPath!
    var selectedRecord: Record?
    var selectedIbadah: Ibadah?
    
    @IBAction override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }
    
    func updateSelected(isPlus: Bool) {
        if selectedIbadah != nil {
            let fillnumber_type = selectedIbadah!.type == "fillnumber"
            var value = { () -> Int in
                if selectedRecord != nil { return self.selectedRecord!.value }
                else { return 0 }
            }()
            
            if selectedRecord != nil && fillnumber_type {
                if (isPlus) { value = value + 1 }
                else { value = value != 0 ? value - 1 : 0 }
            } else {
                if (isPlus) { value = 1 }
                else { value = 0 }
            }
            
            let realm = try! Realm()
            do {
                try realm.write {
                    if selectedRecord != nil { selectedRecord!.value = value }
                }
            } catch {
                print("cannot update selected record")
            }
            
            if selectedIbadah!.unit_name != nil {
                valueLabel.text = String(describing: selectedRecord!.value) + " " + selectedIbadah!.unit_name!
            } else {
                valueLabel.text = selectedRecord!.value > 0 ? "yes" : "no"
            }

            tableView.reloadRows(at: [selectedIndexPath as IndexPath], with: .none)
        }
    }
    
    @IBAction func plusButtonPressed() {
        updateSelected(isPlus: true)
    }
    
    @IBAction func minusButtonPressed() {
        updateSelected(isPlus: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        tableView.register(UINib(nibName: "IbadahTableViewCell", bundle: nil), forCellReuseIdentifier: "ibadahCell")
        tableView.dataSource = self

        /* detail view */
        valueLabel.isHidden = true
        dateButton.isHidden = true
        dateButton.layer.cornerRadius = 8
        dateButton.clipsToBounds = true
        dateButton.text = readableDateFormatter.string(from: currentDate as Date)
        
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
        tableView.isUserInteractionEnabled = false

        let realm = try! Realm()
        listOfIbadahs = Array(realm.objects(Ibadah.self)) as [Ibadah]
        
        if listOfIbadahs.count > 0 {
            APIClient.sharedClient.getUserMutabaahs {
                // print("fetched mutabaahs")
                self.decodeMutabaahsForDate(date: self.currentDate)
                self.loadListOfIbadahs()
            }
        } else {
            APIClient.sharedClient.getListOfIbadahs {
                //print("fetched ibadahs")
                APIClient.sharedClient.getUserMutabaahs {
                    // print("fetched mutabaahs")
                    self.listOfIbadahs = Array(realm.objects(Ibadah.self)) as [Ibadah]
                    self.decodeMutabaahsForDate(date: self.currentDate)
                    self.loadListOfIbadahs()
                }
            }
        }
    }
    
    func decodeMutabaahsForDate(date: NSDate) {
        let realm = try! Realm()
        
        let ds = dateFormatter.string(from:date as Date)
        let queryfilter = NSPredicate(format: "date = %@", ds)
        let mutabaah = Array(realm.objects(Mutabaah.self).filter(queryfilter)) as [Mutabaah]
        
        if mutabaah.count == 0 {
            // create a new mutabaah record
            currentMutabaah = Mutabaah(date: ds)
            for i in listOfIbadahs {
                let rec = Record(id: i._id, value: 0)
                do {
                    try realm.write {
                        realm.add(currentMutabaah)
                        currentMutabaah.records.append(rec)
                    }
                } catch {
                    print("cannot create new mutabaah realm")
                }
            }
        } else {
            currentMutabaah = mutabaah.first!
        }
    }
    
    
    func loadListOfIbadahs() {
        spinner.stopAnimating()
        spinner0.stopAnimating()
        valueLabel.isHidden = false
        dateButton.isHidden = false
        ibadahLabel.isHidden = false
        
        //controlView.slideInFromBottom(0.5)
        controlView.isHidden = false
        
        tableView.isUserInteractionEnabled = true
        
        valueLabel.text = "Pilih!"
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .fade)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ibadahLabel.isHidden = true
        
        plusButton.text = ">"
        minusButton.text = "<"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        selectedIndex = -1000
        
        APIClient.sharedClient.postMutabaah(mutabaah: currentMutabaah, success: { 
            // do
            }) { (error) in
                print(error)
        }
    }
    
    // MARK: - Table view data source
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfIbadahs.count
    }
    
    func updateCellValues(record: Record, ibadah: Ibadah, cell: IbadahTableViewCell) -> IbadahTableViewCell {
        cell.ibadahTarget.text = ibadah.target.separate("_")
        cell.ibadahLabel.text = ibadah.name.separate("_")
        let fillnum_type = ibadah.type == "fillnumber"
        
        if fillnum_type {
            cell.ibadahValue.text = String(describing: record.value)
        } else {
            cell.ibadahValue.text = record.value > 0 ? "yes" : "no"
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ibadahCell", for: indexPath as IndexPath) as! IbadahTableViewCell
        
        if (selectedRecord != nil && selectedIbadah != nil) {
            cell = updateCellValues(record: selectedRecord!, ibadah: selectedIbadah!, cell: cell)
        }
        
        let ibadah: Ibadah!
        
        if indexPath.row < listOfIbadahs.count {
            ibadah = listOfIbadahs[indexPath.row]
        } else {
            return cell
        }
        
        if indexPath.row < currentMutabaah.records.count {
            let record = currentMutabaah.records[indexPath.row]
            cell = updateCellValues(record: record, ibadah: ibadah, cell: cell)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ibadah = listOfIbadahs[indexPath.row]
        let record = currentMutabaah.records.first(where: { (r) -> Bool in
            return r.ibadah_id == ibadah._id
        })
        
        ibadahLabel.isHidden = false
        if indexPath.row != selectedIndex {
            valueLabel.slideInFromBottom(0.5)
            ibadahLabel.slideInFromBottom(0.5)
            
            ibadahLabel.text = ibadah.name.separateAndCapitalize("_")
            
            if (ibadah.type == "yesno") {
                plusButton.text = "yes"
                minusButton.text = "no"
            } else {
                plusButton.text = ">"
                minusButton.text = "<"
            }
            
            if record == nil { valueLabel.text = "Not Yet" } // not in records
            else {
                if ibadah.unit_name != nil {
                    valueLabel.text = String(describing: record!.value) + " " + ibadah.unit_name!
                } else {
                    valueLabel.text = record!.value > 0 ? "yes" : "no"
                }
            }
            selectedIbadah = ibadah
            selectedRecord = record
        }
        selectedIndex = indexPath.row
        selectedIndexPath = indexPath
    }
}
