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
import THCalendarDatePicker
import FontAwesome_swift


class MutabaahViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, THDatePickerDelegate {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var ibadahLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var nextDateButton: UIButton!
    @IBOutlet weak var prevDateButton: UIButton!
    
    /* detail view */
    @IBOutlet weak var valueLabel: UILabel!
    
    var spinner = UIActivityIndicatorView()
    var spinner0 = UIActivityIndicatorView()
    let dateFormatter = DateFormatter().defaultDateFormatter()
    let readableDateFormatter = DateFormatter().readableDateFormatter()
    var currentDate: Date? = Date()
    var listOfIbadahs = [Ibadah]()
    var currentMutabaah = Mutabaah()
    var selectedIndex = -1000
    var selectedIndexPath: IndexPath!
    var selectedRecord: Record?
    var selectedIbadah: Ibadah?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        tableView.register(UINib(nibName: "IbadahTableViewCell", bundle: nil), forCellReuseIdentifier: "ibadahCell")
        tableView.dataSource = self
        
        nextDateButton.titleLabel?.font = UIFont.fontAwesomeOfSize(20.0)
        prevDateButton.titleLabel?.font = UIFont.fontAwesomeOfSize(20.0)
        nextDateButton.text = String.fontAwesomeIconWithName(.CaretRight)
        prevDateButton.text = String.fontAwesomeIconWithName(.CaretLeft)
        
        /* detail view */
        valueLabel.isHidden = true
        dateButton.isHidden = true
        dateButton.layer.cornerRadius = 8
        dateButton.clipsToBounds = true
        dateButton.text = readableDateFormatter.string(from: currentDate!)
        
        /* control view */
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
        
        let realm = APIClient.sharedClient.realm!
        listOfIbadahs = Array(realm.objects(Ibadah.self)) as [Ibadah]
        print(realm.configuration.fileURL)
        
        
        if listOfIbadahs.count > 0 {
            APIClient.sharedClient.getUserMutabaahs {
                // print("fetched mutabaahs")
                self.decodeMutabaahsForDate(date: self.currentDate!)
            }
        } else {
            APIClient.sharedClient.getListOfIbadahs {
                //print("fetched ibadahs")
                APIClient.sharedClient.getUserMutabaahs {
                    //print("fetched mutabaahs")
                    self.listOfIbadahs = Array(realm.objects(Ibadah.self)) as [Ibadah]
                    self.decodeMutabaahsForDate(date: self.currentDate!)
                }
            }
        }
    }
    
    @IBAction override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        APIClient.sharedClient.postMutabaah(mutabaah: currentMutabaah, success: {
            // do
        }) { (error) in
            print(error)
        }
    }
    
    lazy var datePicker: THDatePickerViewController = {
        var dp = THDatePickerViewController.datePicker()!
        dp.delegate = self
        dp.setAllowClearDate(false)
        dp.setDisableYearSwitch(true)
        dp.setClearAsToday(true)
        dp.setAutoCloseOnSelectDate(true)
        dp.setAllowSelectionOfSelectedDate(true)
        dp.setDisableHistorySelection(false)
        dp.setDisableFutureSelection(false)
        dp.selectedBackgroundColor = UIColor(red: 125/255.0, green: 208/255.0, blue: 0/255.0, alpha: 1.0)
        dp.currentDateColor = UIColor(red: 242/255.0, green: 121/255.0, blue: 53/255.0, alpha: 1.0)
        dp.currentDateColorSelected = UIColor.yellow
        return dp
    }()
    
    @IBAction func nextDatePressed(sender: AnyObject?) {
        let nextDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: currentDate!)
        self.currentDate = nextDate
        self.decodeMutabaahsForDate(date: nextDate!)
    }
    
    @IBAction func prevDatePressed(sender: AnyObject?) {
        let prevDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: currentDate!)
        self.currentDate = prevDate
        self.decodeMutabaahsForDate(date: prevDate!)
    }
    
    
    @IBAction func dateButtonPressed(sender: AnyObject?) {
        datePicker.date = currentDate as Date!
        //datePicker.setDateHasItemsCallback({(date: NSDate!) -> Bool in
        //
        //})
        presentSemiViewController(datePicker, withOptions: [
            KNSemiModalOptionKeys.pushParentBack.takeRetainedValue() : NSNumber(value: false),
            KNSemiModalOptionKeys.animationDuration.takeRetainedValue() : NSNumber(value: 0.2),
            KNSemiModalOptionKeys.parentAlpha.takeRetainedValue() : NSNumber(value: 1.0),
            //KNSemiModalOptionKeys.transitionStyle.takeRetainedValue() : UIPageViewControllerTransitionStyle.pageCurl
            ])
    }
    
    public func datePickerDonePressed(_ datePicker: THDatePickerViewController!) {
        self.dismissSemiModalView()
        if let selectedDate = datePicker.selectedDates.first as? Date {
            self.currentDate = selectedDate
            self.decodeMutabaahsForDate(date: selectedDate)
        }
    }
    
    public func datePickerCancelPressed(_ datePicker: THDatePickerViewController!) {
        //
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
            
            let realm = APIClient.sharedClient.realm!
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
                valueLabel.text = selectedRecord!.value > 0 ? "Yes" : "No"
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
    
    func decodeMutabaahsForDate(date: Date) {
        let realm = APIClient.sharedClient.realm!
        
        let ds = dateFormatter.string(from:date)
        let queryfilter = NSPredicate(format: "date = %@", ds)
        let mutabaah = Array(realm.objects(Mutabaah.self).filter(queryfilter)) as [Mutabaah]
        
        if mutabaah.count == 0 {
            // create a new mutabaah record
            currentMutabaah = Mutabaah(date: ds)
            try! realm.write { realm.add(currentMutabaah) }
        } else {
            currentMutabaah = mutabaah.first!
        }
        
        for i in listOfIbadahs {
            let q = NSPredicate(format: "ibadah_id = %@", i._id)
            let recs = currentMutabaah.records.filter(q)
            
            if recs.count > 0 {
                // TODO?
            } else {
                let rec = Record(id: i._id, value: 0)
                try! realm.write {
                    currentMutabaah.records.append(rec)
                }

            }
        }
        
        self.loadListOfIbadahs()
    }
    
    
    func loadListOfIbadahs() {
        spinner.stopAnimating()
        spinner0.stopAnimating()
        valueLabel.isHidden = false
        dateButton.isHidden = false
        ibadahLabel.isHidden = false
        
        controlView.isHidden = false
        
        selectedRecord = nil
        selectedIbadah = nil
        selectedIndexPath = IndexPath()
        selectedIndex = -1000
        
        tableView.isUserInteractionEnabled = true
        
        dateButton.text = readableDateFormatter.string(from: currentDate!)
        
        valueLabel.text = "*"
        tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: .fade)
    }
    
    func updateControlButtons(ibadah: Ibadah?) {
        plusButton.titleLabel?.font = UIFont.fontAwesomeOfSize(20.0)
        minusButton.titleLabel?.font = UIFont.fontAwesomeOfSize(20.0)
        
        if (ibadah == nil || ibadah?.type == "fillnumber") {
            plusButton.setTitle(String.fontAwesomeIconWithName(.ArrowUp), for: .normal)
            minusButton.setTitle(String.fontAwesomeIconWithName(.ArrowDown), for: .normal)
        } else {
            plusButton.setTitle(String.fontAwesomeIconWithName(.Check), for: .normal)
            minusButton.setTitle(String.fontAwesomeIconWithName(.Close), for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ibadahLabel.isHidden = true
        
        updateControlButtons(ibadah: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        selectedIndex = -1000
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
            //ibadahLabel.slideInFromBottom(0.5)
            ibadahLabel.fadeIn(0.5)
            
            ibadahLabel.text = ibadah.name.separateAndCapitalize("_")
            
            updateControlButtons(ibadah: ibadah)
            
            if record == nil { valueLabel.text = "Not Yet" } // not in records
            else {
                if ibadah.unit_name != nil {
                    valueLabel.text = String(describing: record!.value) + " " + ibadah.unit_name!
                } else {
                    valueLabel.text = record!.value > 0 ? "Yes" : "No"
                }
            }
            selectedIbadah = ibadah
            selectedRecord = record
        }
        selectedIndex = indexPath.row
        selectedIndexPath = indexPath
    }
}
