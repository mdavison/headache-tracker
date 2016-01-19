//
//  Year.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/13/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import Foundation

class Year {
    
    var number = 0
    var headaches: [Headache] // this gets ALL headaches, not just headaches for this year
    var weeks = [Week]()
    var allYears = [Int]()
    var weeksForYears = [Int: [Int]]()
    var monthsForYears = [Int: [Int]]()
    var headachesForPastYear = [Headache]()
    
    init(headaches: [Headache]) {
        self.headaches = headaches
        loadWeeksForYears()
        loadHeadachesForPastYear()
    }
    
    private func loadWeeksForYears() {
        let calendar = NSCalendar.currentCalendar()
        
        for headache in headaches {
            let headacheWeek = calendar.components(NSCalendarUnit.WeekOfYear, fromDate: headache.date!).weekOfYear
            let headacheMonth = calendar.components(NSCalendarUnit.Month, fromDate: headache.date!).month
            let headacheYear = calendar.components(NSCalendarUnit.Year, fromDate: headache.date!).year
            
            // Add the year as the dictionary key for weeksForYears
            if !weeksForYears.keys.contains(headacheYear) {
                weeksForYears[headacheYear] = []
                // Populate the allYears property
                allYears.append(headacheYear)
            }
            
            // Add the year as the dictionary key for monthsForYears
            if !monthsForYears.keys.contains(headacheYear) {
                monthsForYears[headacheYear] = []
            }
            
            // Append the week number to the appropriate year
            if let y = weeksForYears[headacheYear] { // y = array of week numbers
                if !y.contains(headacheWeek) {
                    weeksForYears[headacheYear]?.append(headacheWeek)
                }
            }
            
            // Append the month to the appropriate year
            if let y = monthsForYears[headacheYear] { // y = array of month numbers
                if !y.contains(headacheMonth) {
                    monthsForYears[headacheYear]?.append(headacheMonth)
                }
            }
        }
        
        //print(monthsForYears)
    }

    private func loadHeadachesForPastYear() {
        let calendar = NSCalendar.currentCalendar()
        
        if let oneYearAgo = calendar.dateByAddingUnit(.Year, value: -1, toDate: NSDate(), options: []) {
            //print("one year ago: \(oneYearAgo)")
            for headache in headaches {
//                print("headache date: \(headache.date)")
//                print(headache.date.compare(oneYearAgo) == NSComparisonResult.OrderedDescending)
//                print(headache.date.compare(oneYearAgo) == NSComparisonResult.OrderedSame)
                
                if (headache.date!.compare(oneYearAgo) == NSComparisonResult.OrderedDescending) ||
                    (headache.date!.compare(oneYearAgo) == NSComparisonResult.OrderedSame) {
                        headachesForPastYear.append(headache)
                }
            }
        }

    }
    
}
