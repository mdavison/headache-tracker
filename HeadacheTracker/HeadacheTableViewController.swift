//
//  HeadacheTableViewController.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/10/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class HeadacheTableViewController: UITableViewController, HeadacheDetailTableViewControllerDelegate {
    
    var coreDataStack: CoreDataStack!
    var headaches = [Headache]()
    var fetchedResultsController: NSFetchedResultsController!
    
    struct Storyboard {
        static let HeadacheCellReuseIdentifier = "HeadacheCell"
        static let AddHeadacheSegueIdentifier = "AddHeadache"
        static let EditHeadacheSegueIdentifier = "EditHeadache"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Headaches List", comment: "list of headaches")
        loadHeadaches()
        toggleNoDataLabel()
        fetchedResultsController.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90.0
        
        Theme.setup(withView: view, navigationBar: navigationController?.navigationBar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.HeadacheCellReuseIdentifier, forIndexPath: indexPath) as! HeadacheListTableViewCell

        let headache = fetchedResultsController.objectAtIndexPath(indexPath) as! Headache
        
        configureTableCell(cell, withHeadache: headache)
        
        return cell
    }
    
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        if editingStyle == .Delete {
            let headache = fetchedResultsController.objectAtIndexPath(indexPath) as? Headache
            let headacheYear = headache?.year?.valueForKey("number") as! Int
            
            coreDataStack.context.deleteObject(headache!)
            
            // If there are no more headaches for the deleted headache Year, delete the Year
            deleteYearIfNoHeadaches(headacheYear)
            
            coreDataStack.saveContext()
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
        
    
    
    // MARK: HeadacheDetailTableViewControllerDelegate
    
    func headacheDetailTableViewControllerDidCancel(controller: HeadacheDetailTableViewController) {
        dismissViewControllerAnimated(true, completion: nil)
        // Reload data in case medications were changed
        tableView.reloadData()
    }
    
    func headacheDetailTableViewController(controller: HeadacheDetailTableViewController, didFinishAddingHeadache headache: Headache) {
        tableView.reloadData()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func headacheDetailTableViewController(controller: HeadacheDetailTableViewController, didFinishEditingHeadache headache: Headache) {
        if let index = headaches.indexOf(headache) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? HeadacheListTableViewCell {
                configureTableCell(cell, withHeadache: headache)
            }
        }
        headaches.sortInPlace({ $0.date!.compare($1.date!) == NSComparisonResult.OrderedDescending })
        tableView.reloadData()

        dismissViewControllerAnimated(true, completion: nil)
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.AddHeadacheSegueIdentifier {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! HeadacheDetailTableViewController
            controller.delegate = self
            controller.coreDataStack = coreDataStack
            controller.fetchedResultsController = fetchedResultsController
        } else if segue.identifier == Storyboard.EditHeadacheSegueIdentifier {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! HeadacheDetailTableViewController
            controller.delegate = self
            controller.coreDataStack = coreDataStack
            controller.fetchedResultsController = fetchedResultsController
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                controller.headacheToEdit = fetchedResultsController.objectAtIndexPath(indexPath) as? Headache
            }
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func export(sender: UIBarButtonItem) {
        if let data = prepareCSVData() {
            let filename = getDocumentsDirectory().stringByAppendingPathComponent("headaches.csv")
            
            data.writeToFile(filename, atomically: true)
            
            let url = NSURL(fileURLWithPath: filename)
            
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.barButtonItem = sender
            }

            presentViewController(activityViewController, animated: true, completion: nil)

        } else {
            NSLog("Unable to prepare data")
        }
    }
    
    
    
    
    // MARK: - Helper Methods
    
    private func loadHeadaches() {
        let headacheFetch = NSFetchRequest(entityName: "Headache")
        headacheFetch.relationshipKeyPathsForPrefetching = ["year"]
        headacheFetch.relationshipKeyPathsForPrefetching = ["medications"]
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        headacheFetch.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: headacheFetch, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error) " + "description: \(error.localizedDescription)")
        }
        
    }
    
    private func fetchYears() -> NSFetchedResultsController {
        let yearFetch = NSFetchRequest(entityName: "Year")
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        yearFetch.sortDescriptors = [sortDescriptor]
        
        let yearFetchedResultsController = NSFetchedResultsController(fetchRequest: yearFetch, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try yearFetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error) " + "description: \(error.localizedDescription)")
        }
        
        return yearFetchedResultsController
    }
    
    private func fetchYearFor(number: Int) -> NSFetchedResultsController {
        let yearFetch = NSFetchRequest(entityName: "Year")
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        yearFetch.sortDescriptors = [sortDescriptor]
        yearFetch.predicate = NSPredicate(format: "number == %d", number)
        
        let yearFetchedResultsController = NSFetchedResultsController(fetchRequest: yearFetch, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try yearFetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error) " + "description: \(error.localizedDescription)")
        }

        return yearFetchedResultsController
    }
    
    private func fetchHeadachesFor(year: Int) -> NSFetchedResultsController {
        let headachesForYearFetch = NSFetchRequest(entityName: "Headache")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        headachesForYearFetch.sortDescriptors = [sortDescriptor]
        headachesForYearFetch.relationshipKeyPathsForPrefetching = ["year"]
        headachesForYearFetch.predicate = NSPredicate(format: "year.number == %d", year)
        
        let headachesForYearFetchedResultsController = NSFetchedResultsController(fetchRequest: headachesForYearFetch, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try headachesForYearFetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error) " + "description: \(error.localizedDescription)")
        }

        return headachesForYearFetchedResultsController
    }
    
    private func configureTableCell(cell: HeadacheListTableViewCell, withHeadache headache: Headache) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        let calendar = NSCalendar.currentCalendar()
        let compareToToday = calendar.compareDate(headache.date!, toDate: NSDate(), toUnitGranularity: .Day)
        let yesterday = calendar.dateByAddingUnit(.Day, value: -1, toDate: NSDate(), options: [])
        let compareToYesterday = calendar.compareDate(headache.date!, toDate: yesterday!, toUnitGranularity: .Day)
        if compareToToday == .OrderedSame {
            cell.dateLabel.text = "Today"
        } else if compareToYesterday == .OrderedSame {
            cell.dateLabel.text = "Yesterday"
        } else {
            cell.dateLabel.text = dateFormatter.stringFromDate(headache.date!)
        }
        
        cell.severityLabel.text = headache.severityDescription()
        
        let severityColor = headache.severityColor()
        if let red = severityColor["red"], green = severityColor["green"], blue = severityColor["blue"] {
            cell.severityLabel.textColor = UIColor.init(red: red, green: green, blue: blue, alpha: 1)
        }
        
        cell.medicationsLabel.text = getMedicationsAndDosesToDisplay(forHeadache: headache)
    }
    
    private func deleteYearIfNoHeadaches(headacheYear: Int) {
        let headachesForYearFetchedResultsController = fetchHeadachesFor(headacheYear)
        
        // If there are no headaches for this year
        if headachesForYearFetchedResultsController.fetchedObjects!.isEmpty {
            // Fetch the year
            let yearFetchedResultsController = fetchYearFor(headacheYear)
            
            // Delete the year
            if let yearToDelete = yearFetchedResultsController.fetchedObjects?.first as? Year {
                coreDataStack.context.deleteObject(yearToDelete)
            }
        }
    }
    
    private func toggleNoDataLabel() {
        if let label = view.viewWithTag(1000) {
            label.removeFromSuperview()
        }
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
            label.text = "There are no headaches"
            label.textColor = UIColor.lightGrayColor()
            label.textAlignment = .Center
            label.font = UIFont.preferredFontForTextStyle("body")
            label.tag = 1000
            view.addSubview(label)
        }
    }
    
    private func getMedicationsAndDosesToDisplay(forHeadache headache: Headache) -> String {
        var medicationDoses = [Medication: Int]()
        
        for medication in headache.medications! {
            if let dose = fetchDose(forMedication: medication, andHeadache: headache) {
                medicationDoses[medication] = Int(dose.quantity!)
            }
        }
        
        var displayArray = [String]()
        for medDose in medicationDoses {
            displayArray.append("\(medDose.1) \(medDose.0.name!)")
        }
        
        return displayArray.joinWithSeparator(", ")
    }
    
    private func fetchDose(forMedication medication: Medication, andHeadache headache: Headache) -> Dose? {
        let fetchRequest = NSFetchRequest(entityName: "Dose")
        fetchRequest.predicate = NSPredicate(format: "headache.date == %@ AND medication.name == %@", headache.date!, medication.name!)
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Dose]
            if results.count > 0 {
                return results.last
            }
        } catch let error as NSError {
            print("Error: \(error) " + "description \(error.localizedDescription)")
        }
        
        return nil
    }

    private func prepareCSVData() -> NSData? {
        var csvString = "Headache Date,Severity,Medications\n"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        if let headaches = fetchedResultsController.fetchedObjects as? [Headache] {
            for headache in headaches {
                let medicationsString = getMedicationsAndDosesToDisplay(forHeadache: headache)

                if let date = headache.date, let severity = headache.severity {
                    let formattedDate = dateFormatter.stringFromDate(date)
                    
                    csvString = csvString + "\"\(formattedDate)\",\(severity),\"\(medicationsString)\"\n"
                }
            }
        }
        
        return csvString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    }
    
    private func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}



extension HeadacheTableViewController: NSFetchedResultsControllerDelegate {

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
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! HeadacheListTableViewCell
            let headache = fetchedResultsController.objectAtIndexPath(indexPath!) as! Headache
            configureTableCell(cell, withHeadache: headache)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
        toggleNoDataLabel()
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

extension HeadacheTableViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        switch result {
        case MFMailComposeResultCancelled:
            NSLog("Mail cancelled");
        case MFMailComposeResultSaved:
            NSLog("Mail saved");
        case MFMailComposeResultSent:
            NSLog("Mail sent");
        case MFMailComposeResultFailed:
            NSLog("Mail sent failure: \(error?.localizedDescription)");
        default:
            break;
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}
