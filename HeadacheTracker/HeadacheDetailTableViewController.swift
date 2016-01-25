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
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var severitySlider: UISlider!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var coreDataStack: CoreDataStack!
    weak var delegate: HeadacheDetailTableViewControllerDelegate?
    var headacheToEdit: Headache?
    var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let headache = headacheToEdit {
            title = "Edit Headache"
            datePicker.date = headache.date!
            severitySlider.value = Float(headache.severity!)
        }
        
        // Prevent future dates
        datePicker.maximumDate = NSDate()
        
        validateSelectedDate(datePicker.date)
    }
    
    // MARK: - UITableViewControllerDelegate
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return "Value of slider: \(lroundf(severitySlider.value))"
        } else {
            return ""
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
            
            addHeadacheToYear(headache)
            
            coreDataStack.saveContext()
            
            delegate?.headacheDetailTableViewController(self, didFinishEditingHeadache: headache)
            
        } else {
            
            let headacheEntity = NSEntityDescription.entityForName("Headache", inManagedObjectContext: coreDataStack.context)
            let headache = Headache(entity: headacheEntity!, insertIntoManagedObjectContext: coreDataStack.context)
            headache.date = datePicker.date
            headache.severity = NSNumber(integer: lroundf(severitySlider.value))
            
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
        tableView(tableView, titleForFooterInSection: 1)
        tableView.reloadData()
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

    
}
