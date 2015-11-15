//
//  MonthViewController.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/14/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import UIKit

class MonthViewController: UITableViewController, UITabBarControllerDelegate {

    var dataModel: DataModel!
    var yearModel: Year?
    var monthModel: Month?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        yearModel = Year(headaches: dataModel.headaches)
        monthModel = Month(headaches: dataModel.headaches)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (yearModel?.weeksForYears.count)!
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let year = yearModel?.allYears[section] {
            if let rowCount = yearModel?.monthsForYears[year]?.count {
                return rowCount
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let yearNumber = yearModel?.allYears[section] {
            return "\(yearNumber)"
        }
        return ""
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MonthCell", forIndexPath: indexPath)
        if let year = yearModel?.allYears[indexPath.section] {
            if let month = yearModel?.monthsForYears[year]?[indexPath.row] {
                configureTableCell(cell, withMonth: month, withYear: year)
            }
        }

        return cell
    }
    
    
    private func configureTableCell(cell: UITableViewCell, withMonth month: Int, withYear year: Int) {
        let calendar = NSCalendar.currentCalendar()
        let dayComponent = NSDateComponents()

        dayComponent.month = month
        dayComponent.year = year
        let date = calendar.dateFromComponents(dayComponent)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM";
        
        var detailText = ""
        
        if let numberOfHeadaches = monthModel?.headachesForMonths[month]?.count {
            detailText = "\(numberOfHeadaches)"
        }
        
        cell.textLabel?.text = "\(dateFormatter.stringFromDate(date!))"
        cell.detailTextLabel?.text = detailText
    }

}
