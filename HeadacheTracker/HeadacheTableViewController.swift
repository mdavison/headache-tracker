//
//  HeadacheTableViewController.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/10/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import UIKit

class HeadacheTableViewController: UITableViewController, HeadacheDetailTableViewControllerDelegate {

    var dataModel: DataModel!
    
    struct Storyboard {
        static let HeadacheCellReuseIdentifier = "HeadacheCell"
        static let AddHeadacheSegueIdentifier = "AddHeadache"
        static let EditHeadacheSegueIdentifier = "EditHeadache"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return dataModel.headaches.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.HeadacheCellReuseIdentifier, forIndexPath: indexPath)
        let headache = dataModel.headaches[indexPath.row]

        configureTableCell(cell, withHeadache: headache)
        
        return cell
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
            dataModel.headaches.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            dataModel.saveHeadaches()
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
        let newRowIndex = dataModel.headaches.count
        dataModel.headaches.append(headache)
        
        let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        dismissViewControllerAnimated(true, completion: nil)
        
        dataModel.saveHeadaches()
    }
    
    func headacheDetailTableViewController(controller: HeadacheDetailTableViewController, didFinishEditingHeadache headache: Headache) {
        if let index = dataModel.headaches.indexOf(headache) {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                configureTableCell(cell, withHeadache: headache)
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
        
        dataModel.saveHeadaches()
    }
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.AddHeadacheSegueIdentifier {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! HeadacheDetailTableViewController
            controller.delegate = self            
        } else if segue.identifier == Storyboard.EditHeadacheSegueIdentifier {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! HeadacheDetailTableViewController
            controller.delegate = self
            
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                controller.headacheToEdit = dataModel.headaches[indexPath.row]
            }
        }
    }
    
    
    private func configureTableCell(cell: UITableViewCell, withHeadache headache: Headache) {
        let label = cell.viewWithTag(1000) as! UILabel
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        label.text = dateFormatter.stringFromDate(headache.date)
        cell.detailTextLabel?.text = headache.severityDescription()
    }

}
