//
//  MedicationTableViewController.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 1/27/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit
import CoreData

protocol MedicationTableViewControllerDelegate: class {
    func medicationTableViewControllerDidFinish(controller: MedicationTableViewController)
}

class MedicationTableViewController: UITableViewController {

    var coreDataStack: CoreDataStack!
    var medicationFetchedResultsController = NSFetchedResultsController()
    weak var delegate: MedicationTableViewControllerDelegate?
    
//    var medications = [
//        ["Advil", 0],
//        ["Tylenol", 0],
//        ["Aspirin", 0],
//        ["Aleeve", 0],
//        ["Imitrex", 0],
//        ["GoodStuff", 0],
//        ["KnockMeOut", 0]
//    ]
    
    struct Storyboard {
        static let MedicationCellReuseIdentifier = "MedicationCell"
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        fetchMedications()
        medicationFetchedResultsController.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //return 1
        return medicationFetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return medicationFetchedResultsController.fetchedObjects?.count ?? 0
        let sectionInfo = medicationFetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MedicationCellReuseIdentifier, forIndexPath: indexPath)
        
        configureCell(cell, indexPath: indexPath)
        


        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedMedication = medicationFetchedResultsController.objectAtIndexPath(indexPath) as! Medication
        showMedicationNameAlert(selectedMedication)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let medication = medicationFetchedResultsController.objectAtIndexPath(indexPath) as? Medication
            coreDataStack.context.deleteObject(medication!)
            coreDataStack.saveContext()
            
            // Delete the row from the data source
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - Actions
    
//    @IBAction func cancel() {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
    @IBAction func done() {
        //delegate?.medicationTableViewController(self)
        delegate?.medicationTableViewControllerDidFinish(self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func add(sender: UIBarButtonItem) {
//        let alert = UIAlertController(title: "Add Medication", message: nil, preferredStyle: .Alert)
//        
//        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
//            textField.placeholder = "Medication Name"
//        }
//        
//        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction) -> Void in
//            let nameTextField = alert.textFields!.first
//            let name = nameTextField!.text
//            var nameIsValid = true
//            
//            // check that name is not blank
//            if name!.isEmpty == true {
//                nameIsValid = false
//                self.showInvalidNameAlert("Oops!", message: "Name can't be blank.")
//            }
//            // check that name is not duplicate
//            if self.nameIsDuplicate(ofMedicationName: name!) {
//                nameIsValid = false
//                self.showInvalidNameAlert("Oops!", message: "That name already exists.")
//            }
//            
//            if nameIsValid {
//                let medication = NSEntityDescription.insertNewObjectForEntityForName("Medication", inManagedObjectContext: self.coreDataStack.context) as! Medication
//                medication.name = nameTextField!.text
//                self.coreDataStack.saveContext()
//            }
//            
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) -> Void in
//            print("Cancel")
//        }))
//        
//        presentViewController(alert, animated: true, completion: nil)
        
        showMedicationNameAlert(nil)
    }
    
    
    
    // MARK: - Helper Methods
    
    private func fetchMedications() {
        let fetch = NSFetchRequest(entityName: "Medication")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetch.sortDescriptors = [sortDescriptor]
        
        medicationFetchedResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try medicationFetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error) " + "description: \(error.localizedDescription)")
        }
    }
    
    private func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        if medicationFetchedResultsController.fetchedObjects?.count > 0 {
            if let medication = medicationFetchedResultsController.objectAtIndexPath(indexPath) as? Medication {
                cell.textLabel?.text = medication.name
            }
        }
    }
    
    private func showMedicationNameAlert(medication: Medication?) {
        var alertTitle = ""
        if medication != nil {
            alertTitle = "Edit Medication"
        } else {
            alertTitle = "Add Medication"
        }
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            if medication != nil {
                textField.text = medication?.name
            } else {
                textField.placeholder = "Medication Name"
            }
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction) -> Void in
            let nameTextField = alert.textFields!.first
            let name = nameTextField!.text
            var nameIsValid = true
            
            // check that name is not blank
            if name!.isEmpty == true {
                nameIsValid = false
                self.showInvalidNameAlert("Oops!", message: "Name can't be blank.")
            }
            // check that name is not duplicate
            if self.nameIsDuplicate(ofMedicationName: name!) {
                nameIsValid = false
                self.showInvalidNameAlert("Oops!", message: "That name already exists.")
            }
            
            if nameIsValid {
                if medication != nil {
                    medication?.name = name
                    
                } else { // create new medication
                    let medication = NSEntityDescription.insertNewObjectForEntityForName("Medication", inManagedObjectContext: self.coreDataStack.context) as! Medication
                    medication.name = name
                }
                
                self.coreDataStack.saveContext()
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) -> Void in
            print("Cancel")
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }

    private func nameIsDuplicate(ofMedicationName name: String) -> Bool {
        for medication in medicationFetchedResultsController.fetchedObjects! {
            if medication.name == name {
                return true
            }
        }
        return false
    }

    private func showInvalidNameAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
}


extension MedicationTableViewController: NSFetchedResultsControllerDelegate {
    
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        tableView.reloadData()
//    }

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            configureCell(cell!, indexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        let indexSet = NSIndexSet(index: sectionIndex)
        
        switch type {
        case .Insert:
            tableView.insertSections(indexSet, withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(indexSet, withRowAnimation: .Automatic)
        default:
            break
        }
    }

}
