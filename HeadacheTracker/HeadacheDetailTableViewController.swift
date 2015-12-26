//
//  HeadacheDetailTableViewController.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/10/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import UIKit

protocol HeadacheDetailTableViewControllerDelegate: class {
    func headacheDetailTableViewControllerDidCancel(controller: HeadacheDetailTableViewController)
    func headacheDetailTableViewController(controller: HeadacheDetailTableViewController, didFinishAddingHeadache headache: Headache)
    func headacheDetailTableViewController(controller: HeadacheDetailTableViewController, didFinishEditingHeadache headache: Headache)
}

class HeadacheDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var severitySlider: UISlider!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    weak var delegate: HeadacheDetailTableViewControllerDelegate?
    var headacheToEdit: Headache?
    var headaches = [Headache]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let headache = headacheToEdit {
            title = "Edit Headache"
            datePicker.date = headache.date
            severitySlider.value = Float(headache.severity)
        }
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
            headache.severity = lroundf(severitySlider.value)
            
            delegate?.headacheDetailTableViewController(self, didFinishEditingHeadache: headache)
        } else {
            let headache = Headache()
            headache.date = datePicker.date
            headache.severity = lroundf(severitySlider.value)
            
            delegate?.headacheDetailTableViewController(self, didFinishAddingHeadache: headache)
        }
    }
    
    @IBAction func dateChanged(sender: UIDatePicker) {
        doneButton.enabled = true
        let calendar = NSCalendar.currentCalendar()
        
        for headache in headaches {
            var order = calendar.compareDate(headache.date, toDate: sender.date, toUnitGranularity: .Day)
            if order == .OrderedSame {
                doneButton.enabled = false
                
                // Unless editing that date
                if let editingHeadache = headacheToEdit?.date {
                    order = calendar.compareDate(editingHeadache, toDate: sender.date, toUnitGranularity: .Day)
                    if order == .OrderedSame {
                        doneButton.enabled = true
                    }
                }
            }
        }
    }
    
    @IBAction func severityChanged(sender: UISlider) {
        sender.setValue(Float(lroundf(severitySlider.value)), animated: true)
        tableView(tableView, titleForFooterInSection: 1)
        tableView.reloadData()
    }
    
}
