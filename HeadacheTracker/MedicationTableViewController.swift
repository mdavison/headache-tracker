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

class MedicationTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var addMedicationTextField: UITextField!
    
    var coreDataStack: CoreDataStack!
    var medicationFetchedResultsController = NSFetchedResultsController()
    weak var delegate: MedicationTableViewControllerDelegate?
    
    struct Storyboard {
        static let MedicationCellReuseIdentifier = "MedicationCell"
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMedicationTextField.delegate = self
        fetchMedications()
        medicationFetchedResultsController.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return medicationFetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        var medicationsArray = medicationFetchedResultsController.fetchedObjects as! [Medication]
        let movedMedication = medicationFetchedResultsController.objectAtIndexPath(fromIndexPath) as? Medication
        
        medicationsArray.removeAtIndex(fromIndexPath.row)
        medicationsArray.insert(movedMedication!, atIndex: toIndexPath.row)
        
        var i = 0
        for medication in medicationsArray {
            medication.displayOrder = i
            i++
        }
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let name = textField.text {
            var nameIsValid = true
            
            // Make sure name is not blank
            let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
            let trimmedString = name.stringByTrimmingCharactersInSet(whitespaceSet)

            if trimmedString.characters.count == 0 {
                nameIsValid = false
                textField.text = ""
            }
            
            // Make sure name is not duplicate
            if nameIsDuplicate(ofMedicationName: name) {
                nameIsValid = false
                showInvalidNameAlert("Oops!", message: "That name already exists.")
            }

            if nameIsValid {
                let medication = NSEntityDescription.insertNewObjectForEntityForName("Medication", inManagedObjectContext: self.coreDataStack.context) as! Medication
                medication.name = name
                coreDataStack.saveContext()
                textField.text = ""
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - Actions
    
    @IBAction func done() {
        delegate?.medicationTableViewControllerDidFinish(self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func edit(sender: UIBarButtonItem) {
        editing = !editing
        
        if editing {
            sender.title = "Done"
            sender.style = .Done
            
            doneButton.enabled = false
            doneButton.style = .Plain
        } else {
            sender.title = "Edit"
            sender.style = .Plain
            coreDataStack.saveContext()
            
            doneButton.enabled = true
            doneButton.style = .Done
        }
    }
    
    
    // MARK: - Helper Methods
    
    private func fetchMedications() {
        let fetch = NSFetchRequest(entityName: "Medication")
        let sortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)
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
            textField.autocapitalizationType = UITextAutocapitalizationType.Words
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
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction) -> Void in
            //print("Cancel")
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
            //let cell = tableView.cellForRowAtIndexPath(indexPath!)
            //configureCell(cell!, indexPath: indexPath!)
            
            // http://oleb.net/blog/2013/02/nsfetchedresultscontroller-documentation-bug/
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
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
