//
//  HeadacheDetailTableViewController.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/10/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import UIKit
import CoreData

protocol HeadacheDetailTableViewControllerDelegate: class {
    func headacheDetailTableViewControllerDidCancel(controller: HeadacheDetailTableViewController)
    func headacheDetailTableViewController(controller: HeadacheDetailTableViewController, didFinishAddingHeadache headache: Headache)
    func headacheDetailTableViewController(controller: HeadacheDetailTableViewController, didFinishEditingHeadache headache: Headache)
}

class HeadacheDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    weak var datePicker: UIDatePicker!
    weak var severitySlider: UISlider!
    
    var coreDataStack: CoreDataStack!
    weak var delegate: HeadacheDetailTableViewControllerDelegate?
    var headacheToEdit: Headache?
    var fetchedResultsController: NSFetchedResultsController!
    var medications = [Medication]()
    var selectedMedications = [Medication]()
    
    struct Storyboard {
        static let DatePickerCellReuseIdentifier = "DatePickerCell"
        static let SeverityCellReuseIdentifier = "SeverityCell"
        static let MedicationsCellReuseIdentifier = "MedicationsCell"
        static let MedicationsListCellReuseIdentifier = "MedicationsListCell"
        static let ManageMedicationSegueIdentifier = "ManageMedications"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchMedications()
        
        if (headacheToEdit != nil) {
            title = "Edit Headache"
            setSelectedMedications()
        }
        
        // Prevent future dates
        //datePicker.maximumDate = NSDate()
        
        //validateSelectedDate(datePicker.date)
    }
    
    
    // MARK: - UITableViewController Data Source Methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2:
            return medications.count
        default: return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0: // DATEPICKER
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.DatePickerCellReuseIdentifier, forIndexPath: indexPath) as! DatePickerTableViewCell
            datePicker = cell.datePicker
            
            if let headache = headacheToEdit {
                cell.datePicker.date = headache.date!
            }
            
            validateSelectedDate(cell.datePicker.date)
            
            return cell
        case 1: // SEVERITY
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.SeverityCellReuseIdentifier, forIndexPath: indexPath) as! SeverityTableViewCell
            severitySlider = cell.severitySlider
            if let headache = headacheToEdit {
                cell.severitySlider.value = Float(headache.severity!)
            }
            
            return cell 
        case 2: // MEDICATIONS LIST
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MedicationsListCellReuseIdentifier, forIndexPath: indexPath) as! MedicationsListTableViewCell

            cell.textLabel?.text = medications[indexPath.row].name
            cell.detailTextLabel?.text = countMedications(forIndexPath: indexPath)
            
            if selectedMedications.indexOf(medications[indexPath.row]) != nil {
                cell.accessoryType = .Checkmark
            }
            
            return cell
        default: // MANAGE MEDICATIONS
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MedicationsCellReuseIdentifier, forIndexPath: indexPath) as! MedicationsTableViewCell
            return cell
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let medicationJustSelected = medications[indexPath.row]
        let indexOfMedicationJustSelected = selectedMedications.indexOf(medicationJustSelected)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if indexOfMedicationJustSelected == nil {
            selectedMedications.append(medicationJustSelected)
            cell?.accessoryType = .Checkmark
        } else {
            selectedMedications.removeAtIndex(indexOfMedicationJustSelected!)
            cell?.accessoryType = .None
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 2 {
            return true
        } else {
            return false
        }
    }
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            // Delete the row from the data source
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */
    
//    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        
//        let button = UITableViewRowAction(style: .Default, title: "Clear", handler: { (action, indexPath) in
//            //self.medications[indexPath.row][1] = 0
//            
//            self.clearMedication(atIndexPath: indexPath)
//            
//            let cell = tableView.cellForRowAtIndexPath(indexPath)
//            cell!.detailTextLabel?.text = ""
//            //tableView.reloadData()
//            tableView.setEditing(false, animated: true)
//        })
//        button.backgroundColor = UIColor.orangeColor()
//        
//        return [button]
//    }

    
    
    // MARK: - UITableViewControllerDelegate
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Date"
        case 1: return "Severity"
        case 2: return "Medications"
        default: return ""
        }
    }
    
//    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        switch section {
//        case 1:
//            if let severity = severitySlider {
//                return "Value of slider: \(lroundf(severity.value))"
//            } else {
//                if (headacheToEdit != nil) {
//                    return "Value of slider: \(headacheToEdit?.severity)"
//                } else {
//                    return "Value of slider: 3"
//                }
//            }
//        default: return ""
//        }
//    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 217
        case 1: return 90
        default: return UITableViewAutomaticDimension
        }
    }
    
    // Change swipe to delete text to "Clear"
//    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
//        return "Clear"
//    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.ManageMedicationSegueIdentifier {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! MedicationTableViewController
            controller.delegate = self
            controller.coreDataStack = coreDataStack
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func cancel() {
        delegate?.headacheDetailTableViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        if let headache = headacheToEdit {
            headache.date = datePicker.date
            headache.severity = NSNumber(integer: lroundf(severitySlider.value))
            headache.medications = NSSet(array: selectedMedications)
            
            addHeadacheToYear(headache)
            
            coreDataStack.saveContext()
            
            delegate?.headacheDetailTableViewController(self, didFinishEditingHeadache: headache)
            
        } else {
            
            let headacheEntity = NSEntityDescription.entityForName("Headache", inManagedObjectContext: coreDataStack.context)
            let headache = Headache(entity: headacheEntity!, insertIntoManagedObjectContext: coreDataStack.context)
            headache.date = datePicker.date
            headache.severity = NSNumber(integer: lroundf(severitySlider.value))
            headache.medications = NSSet(array: selectedMedications)
            
            addHeadacheToYear(headache)
            
            coreDataStack.saveContext()
            
            delegate?.headacheDetailTableViewController(self, didFinishAddingHeadache: headache)
        }
    }
    
    @IBAction func dateChanged(sender: UIDatePicker) {
        doneButton.enabled = true
        validateSelectedDate(sender.date)
    }
    
    @IBAction func severityChanged(sender: UISlider) {
        sender.setValue(Float(lroundf(severitySlider.value)), animated: true)
    }
    
    
    // MARK: - Helper Methods
    
    private func setHeadacheYear() -> Year {
        var headacheYear: Year!
        
        let calendar = NSCalendar.currentCalendar()
        let date = datePicker.date
        let components = calendar.components([.Month, .Day, .Year], fromDate: date)
        
        let yearEntity = NSEntityDescription.entityForName("Year", inManagedObjectContext: coreDataStack.context)
        let yearFetch = NSFetchRequest(entityName: "Year")
        yearFetch.predicate = NSPredicate(format: "number == %@", NSNumber(integer: Int(components.year)))
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(yearFetch) as! [Year]
            
            if results.count > 0 {
                headacheYear = results.first
            } else {
                headacheYear = Year(entity: yearEntity!, insertIntoManagedObjectContext: coreDataStack.context)
                headacheYear.number = NSNumber(integer: Int(components.year))
                try coreDataStack.context.save()
            }
        } catch let error as NSError {
            print("Error: \(error)" + "description \(error.localizedDescription)")
        }
        
        return headacheYear
    }
    
    private func addHeadacheToYear(headache: Headache) {
        let headacheYear = setHeadacheYear()
        
        // Insert the new headache into the Year's headaches set
        let headaches = headacheYear.headaches!.mutableCopy() as! NSMutableOrderedSet
        headaches.addObject(headache)
        headacheYear.headaches = headaches.copy() as? NSOrderedSet

    }
    
    private func validateSelectedDate(date: NSDate) {
        let calendar = NSCalendar.currentCalendar()
        
        for headache in fetchedResultsController.fetchedObjects as! [Headache] {
            var order = calendar.compareDate(headache.date!, toDate: date, toUnitGranularity: .Day)
            if order == .OrderedSame {
                doneButton.enabled = false
                
                // Unless editing that date
                if let editingHeadache = headacheToEdit?.date {
                    order = calendar.compareDate(editingHeadache, toDate: date, toUnitGranularity: .Day)
                    if order == .OrderedSame {
                        doneButton.enabled = true
                    }
                }
            }
        }
    }
    
    private func fetchMedications() {
        // Can't use NSFetchedResultsController in this table view because of the static sections
        let fetchRequest = NSFetchRequest(entityName: "Medication")
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Medication]
            if results.count > 0 {
                medications = results
            }
        } catch let error as NSError {
            print("Error: \(error) " + "description \(error.localizedDescription)")
        }
    
    }
    
    private func setSelectedMedications() {
        if let headacheMeds = headacheToEdit?.medications {
            for med in headacheMeds {
                selectedMedications.append(med as! Medication)
            }
        }
    }
    
    private func countMedications(forIndexPath indexPath: NSIndexPath) -> String {
        var count = 0
        if let headacheMeds = headacheToEdit?.medications {
            for med in headacheMeds {
                if med.name == medications[indexPath.row].name {
                    count++
                }
            }
            if count > 0 {
                return "\(count)"
            }
        }
        return ""
    }
    
    private func clearMedication(atIndexPath indexPath: NSIndexPath) {
        let clearedMedication = medications[indexPath.row]
        
        if let clearedMedicationIndex = selectedMedications.indexOf(clearedMedication) {
            selectedMedications.removeAtIndex(clearedMedicationIndex)
        }
//        for selectedMed in selectedMedications {
//            if selectedMed.name == clearedMedication.name {
//                let index = self.selectedMedications.indexOf(selectedMed)
//                selectedMedications.removeAtIndex(index!)
//            }
//        }
    }

}


extension HeadacheDetailTableViewController: MedicationTableViewControllerDelegate {
    func medicationTableViewControllerDidFinish(controller: MedicationTableViewController) {
        fetchMedications()
        tableView.reloadData()
    }
}