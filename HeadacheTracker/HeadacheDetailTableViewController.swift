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
    var medicationDoses = [Medication: Int]()
    
    struct Storyboard {
        static let DatePickerCellReuseIdentifier = "DatePickerCell"
        static let SeverityCellReuseIdentifier = "SeverityCell"
        static let MedicationsCellReuseIdentifier = "MedicationsCell"
        static let MedicationsListCellReuseIdentifier = "MedicationsListCell"
        static let ManageMedicationSegueIdentifier = "ManageMedications"
    }
    
    deinit {
        //NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchMedications()
        
        if (headacheToEdit != nil) {
            title = "Edit Headache"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Clear the dictionary for each headache so don't keep appending
        medicationDoses.removeAll()
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
            if let dose = fetchDose(forMedication: medications[indexPath.row]) {
                cell.detailTextLabel?.text = "\(dose.quantity!)"
            } else {
                cell.detailTextLabel?.text = ""
            }
            return cell
        default: // MANAGE MEDICATIONS
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MedicationsCellReuseIdentifier, forIndexPath: indexPath) as! MedicationsTableViewCell
            return cell
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let medicationJustSelected = medications[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        // Add dose to array
        var incrementedQuantity = 0
        // Existing headache
        if let dose = fetchDose(forMedication: medicationJustSelected) {
            
            // Has already incremented once
            if let medDose = medicationDoses[medicationJustSelected] {
                incrementedQuantity = medDose + 1
            } else {
                // First time incrementing
                incrementedQuantity = Int(dose.quantity!) + 1
            }
        } else { // New headache
            
            // Has been incremented once
            if let medDose = medicationDoses[medicationJustSelected] {
                incrementedQuantity = medDose + 1
            } else {
                // First time incrementing
                incrementedQuantity = 1
            }
        }
        
        medicationDoses[medicationJustSelected] = incrementedQuantity
        cell?.detailTextLabel?.text = "\(incrementedQuantity)"
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 2 {
            return true
        } else {
            return false
        }
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            // Delete the row from the data source
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // TODO: maybe only show button if there is actually something to clear
        let button = UITableViewRowAction(style: .Default, title: "Clear", handler: { (action, indexPath) in
            self.clearMedication(atIndexPath: indexPath)
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell!.detailTextLabel?.text = ""
            tableView.setEditing(false, animated: true)
        })
        button.backgroundColor = UIColor.orangeColor()
        
        return [button]
    }

    
    
    // MARK: - UITableViewControllerDelegate
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Date"
        case 1: return "Severity"
        case 2: return "Medications"
        default: return ""
        }
    }
    
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
        // Format datePicker date to just save date portion, not time
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDateString = dateFormatter.stringFromDate(datePicker.date)
        let formattedDate = dateFormatter.dateFromString(formattedDateString)
        
        if let headache = headacheToEdit {
            headache.date = formattedDate
            
            headache.severity = NSNumber(integer: lroundf(severitySlider.value))

            addMedicationsAndDoses(toHeadache: headache)
            
            addHeadacheToYear(headache)
            
            coreDataStack.saveContext()
            
            delegate?.headacheDetailTableViewController(self, didFinishEditingHeadache: headache)
            
        } else {
            
            let headacheEntity = NSEntityDescription.entityForName("Headache", inManagedObjectContext: coreDataStack.context)
            let headache = Headache(entity: headacheEntity!, insertIntoManagedObjectContext: coreDataStack.context)
            headache.date = formattedDate
            headache.severity = NSNumber(integer: lroundf(severitySlider.value))
            
            addMedicationsAndDoses(toHeadache: headache)
            
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
        
        //let headaches = headacheYear.headaches!.mutableCopy() as! NSMutableOrderedSet
        //let headaches = headacheYear.headaches as! AnyObject
        //headaches.addObject(headache)
        //headacheYear.headaches = headaches.copy() as? NSOrderedSet
        //headacheYear.headaches = headaches as? Set<Headache>
        
        var headaches = [Headache]() // Mutable array
        for ha in headacheYear.headaches! {
            headaches.append(ha) // Add existing headaches
        }
        headaches.append(headache) // Add new headache
        
        headacheYear.headaches = Set(headaches)

    }
    
    private func addMedicationsAndDoses(toHeadache headache: Headache) {
        if let dosesForHeadache = fetchDoses(forHeadache: headache) {
            for dose in dosesForHeadache {
                // If this dose is in medicationDoses, delete it so we can update, below
                if let _ = medicationDoses.indexOf({ (med, qty) -> Bool in
                    return med == dose.medication
                }) { coreDataStack.context.deleteObject(dose) }
            }
        }
        
        var medications = [Medication]()
        // Put existing headache medications into array
        for med in headache.medications! {
            medications.append(med )
        }
        
        for medicationDose in medicationDoses {
            // Add the new medication
            medications.append(medicationDose.0)
            
            // Add the new dose
            let doseEntity = NSEntityDescription.entityForName("Dose", inManagedObjectContext: coreDataStack.context)
            let dose = Dose(entity: doseEntity!, insertIntoManagedObjectContext: coreDataStack.context)
            dose.quantity = medicationDose.1
            dose.headache = headache
            dose.medication = medicationDose.0
        }
        
        //headache.medications = NSSet(array: medications)
        headache.medications = Set(medications)
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
        let nameSortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Medication]
            medications = results
        } catch let error as NSError {
            print("Error: \(error) " + "description \(error.localizedDescription)")
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

        // Delete the dose, if there is one
        if let dose = fetchDose(forMedication: clearedMedication) {
            coreDataStack.context.deleteObject(dose)
        }
        
        // Delete the medication from the headache
        if let headache = headacheToEdit {
            var newHeadacheMedications = [Medication]()
            
            // Create array of medications that doesn't include the clearedMedication
            for headacheMedication in headache.medications! {
                if (headacheMedication != clearedMedication) {
                    newHeadacheMedications.append(headacheMedication)
                }
            }
            
            // Update headache medications
            //headache.medications = NSSet(array: newHeadacheMedications)
            headache.medications = Set(newHeadacheMedications)
            
        }
        
        // Clear from medicationDoses
        medicationDoses.removeValueForKey(clearedMedication)
    }
    
    
    
    private func fetchDoses() -> [Dose]? {
        let fetchRequest = NSFetchRequest(entityName: "Dose")
        fetchRequest.relationshipKeyPathsForPrefetching = ["headache", "medication"]
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Dose]
            if results.count > 0 {
                return results
            }
        } catch let error as NSError {
            print("Error: \(error) " + "description \(error.localizedDescription)")
        }

        return nil
    }
    
    private func fetchDose(forMedication medication: Medication) -> Dose? {
        if let headacheToEdit = headacheToEdit, medicationName = medication.name  {
            let fetchRequest = NSFetchRequest(entityName: "Dose")
            fetchRequest.predicate = NSPredicate(format: "headache.date == %@ AND medication.name == %@", headacheToEdit.date!, medicationName)
            
            do {
                let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Dose]
                if results.count > 0 {
                    return results.last
                }
            } catch let error as NSError {
                print("Error: \(error) " + "description \(error.localizedDescription)")
            }
        }
        
        return nil
    }
    
    private func fetchDoses(forHeadache headache: Headache) -> [Dose]? {
        let fetchRequest = NSFetchRequest(entityName: "Dose")
        fetchRequest.predicate = NSPredicate(format: "headache.date == %@", headache.date!)
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Dose]
            if results.count > 0 {
                return results
            }
        } catch let error as NSError {
            print("Error: \(error) " + "description \(error.localizedDescription)")
        }
        
        return nil
    }
    
}


extension HeadacheDetailTableViewController: MedicationTableViewControllerDelegate {
    func medicationTableViewControllerDidFinish(controller: MedicationTableViewController, medications: [Medication]) {
        self.medications = medications
        tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Automatic)
    }
}