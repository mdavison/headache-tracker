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
    var managedContext: NSManagedObjectContext!
    var headaches = [Headache]()
    
    struct Storyboard {
        static let HeadacheCellReuseIdentifier = "HeadacheCell"
        static let AddHeadacheSegueIdentifier = "AddHeadache"
        static let EditHeadacheSegueIdentifier = "EditHeadache"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadHeadaches()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return headaches.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.HeadacheCellReuseIdentifier, forIndexPath: indexPath)

        let headache = headaches[indexPath.row]
        configureTableCell(cell, withHeadache: headache)
        
        return cell
    }
    
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //print(indexPath.row)
        if editingStyle == .Delete {
            let headacheToDelete = headaches[indexPath.row] as Headache!
            managedContext.deleteObject(headacheToDelete)
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not delete: \(error)")
            }
            
            headaches.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
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
        let newRowIndex = headaches.count
        headaches.append(headache)
        headaches.sortInPlace({ $0.date!.compare($1.date!) == NSComparisonResult.OrderedDescending })
        
        let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
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
            controller.managedContext = managedContext
        } else if segue.identifier == Storyboard.EditHeadacheSegueIdentifier {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! HeadacheDetailTableViewController
            controller.delegate = self
            controller.managedContext = managedContext
            controller.headaches = headaches
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                controller.headacheToEdit = headaches[indexPath.row]
            }
        }
    }
    
    
    
    // MARK: - Helper Methods
    
    private func loadHeadaches() {
        let headacheFetch = NSFetchRequest(entityName: "Headache")
        headacheFetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let results = try managedContext.executeFetchRequest(headacheFetch) as! [Headache]
            
            if results.count > 0 {
                headaches = results
            }
        } catch let error as NSError {
            print("Error: \(error) " + "description: \(error.localizedDescription)")
        }
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

}
