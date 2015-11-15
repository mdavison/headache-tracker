//
//  WeekViewController.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/11/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import UIKit

class WeekViewController: UITableViewController, UITabBarControllerDelegate {
    
    var dataModel: DataModel!
    var yearModel: Year?
    var weekModel: Week?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        yearModel = Year(headaches: dataModel.headaches)
        weekModel = Week(headaches: dataModel.headaches)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableViewControllerDelegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (yearModel?.weeksForYears.count)!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let year = yearModel?.allYears[section] {
            if let rowCount = yearModel?.weeksForYears[year]?.count {
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
        let cell = tableView.dequeueReusableCellWithIdentifier("WeekCell", forIndexPath: indexPath)
        if let year = yearModel?.allYears[indexPath.section] {
            if let week = yearModel?.weeksForYears[year]?[indexPath.row] {
                configureTableCell(cell, withWeek: week, withYear: year)
            }
        }
    
        return cell
    }


    private func configureTableCell(cell: UITableViewCell, withWeek week: Int, withYear year: Int) {
        let calendar = NSCalendar.currentCalendar()
        let dayComponent = NSDateComponents()
        
        dayComponent.weekOfYear = week
        dayComponent.weekday = 1
        dayComponent.year = year
        var date = calendar.dateFromComponents(dayComponent)
        
        if(week == 1 && calendar.components(.Month, fromDate: date!).month != 1){
            //print(calendar.components(.Month, fromDate: date!).month)
            dayComponent.year = year - 1
            date = calendar.dateFromComponents(dayComponent)
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        var detailText = ""
        
        if let numberOfHeadaches = weekModel?.headachesForWeeks[week]?.count {
            detailText = "\(numberOfHeadaches)"
        }
        
        cell.textLabel?.text = "Week of \(dateFormatter.stringFromDate(date!))"
        cell.detailTextLabel?.text = detailText
    }
    
}
