//
//  HeadacheTableViewController.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/10/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import UIKit
import CoreData

class HeadacheTableViewController: UITableViewController, HeadacheDetailTableViewControllerDelegate {

    //var dataModel: DataModel!
    var coreDataStack: CoreDataStack!
    //var managedContext: NSManagedObjectContext!
    var headaches = [Headache]()
    var fetchedResultsController: NSFetchedResultsController!
    
    struct Storyboard {
        static let HeadacheCellReuseIdentifier = "HeadacheCell"
        static let AddHeadacheSegueIdentifier = "AddHeadache"
        static let EditHeadacheSegueIdentifier = "EditHeadache"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadHeadaches()
        fetchedResultsController.delegate = self
        
//        let yearFetchedResultsController = fetchYears()
//        print(yearFetchedResultsController.fetchedObjects?.count)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //return 1
        return fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return headaches.count
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.HeadacheCellReuseIdentifier, forIndexPath: indexPath)

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
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    }
    
    
    // MARK: HeadacheDetailTableViewControllerDelegate
    
    func headacheDetailTableViewControllerDidCancel(controller: HeadacheDetailTableViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func headacheDetailTableViewController(controller: HeadacheDetailTableViewController, didFinishAddingHeadache headache: Headache) {
//        let newRowIndex = headaches.count
//        headaches.append(headache)
//        headaches.sortInPlace({ $0.date!.compare($1.date!) == NSComparisonResult.OrderedDescending })
//        
//        let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
//        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.reloadData()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func headacheDetailTableViewController(controller: HeadacheDetailTableViewController, didFinishEditingHeadache headache: Headache) {
        if let index = headaches.indexOf(headache) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
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
            //controller.managedContext = managedContext
            controller.coreDataStack = coreDataStack
            controller.fetchedResultsController = fetchedResultsController
        } else if segue.identifier == Storyboard.EditHeadacheSegueIdentifier {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! HeadacheDetailTableViewController
            controller.delegate = self
            //controller.managedContext = managedContext
            controller.coreDataStack = coreDataStack
            //controller.headaches = headaches
            controller.fetchedResultsController = fetchedResultsController
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                //controller.headacheToEdit = headaches[indexPath.row]
                controller.headacheToEdit = fetchedResultsController.objectAtIndexPath(indexPath) as? Headache
            }
        }
    }
    
    
    
    // MARK: - Helper Methods
    
    private func loadHeadaches() {
        let headacheFetch = NSFetchRequest(entityName: "Headache")
        headacheFetch.relationshipKeyPathsForPrefetching = ["year"]
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
    
    private func configureTableCell(cell: UITableViewCell, withHeadache headache: Headache) {
        let label = cell.viewWithTag(1000) as! UILabel
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        label.text = dateFormatter.stringFromDate(headache.date!)
        cell.detailTextLabel?.text = headache.severityDescription()
        let severityColor = headache.severityColor()
        if let red = severityColor["red"], green = severityColor["green"], blue = severityColor["blue"] {
            cell.detailTextLabel?.textColor = UIColor.init(red: red, green: green, blue: blue, alpha: 1)
        }
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
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            let headache = fetchedResultsController.objectAtIndexPath(indexPath!) as! Headache
            configureTableCell(cell!, withHeadache: headache)
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
