//
//  Month.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/14/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import Foundation

class Month {
    
    var number = 0 // Month number
    var headaches = [Headache]() // this gets ALL headaches, not just headaches for this week
    var headachesForMonths = [Int: [Headache]]()
    var headachesForPastMonth = [Headache]()

    init(headaches: [Headache]) {
        self.headaches = headaches
        loadHeadachesForMonths()
        loadHeadachesForPastMonth()
    }

    private func loadHeadachesForMonths() {
        let calender = NSCalendar.currentCalendar()
        
        for headache in headaches {
            let headacheMonth = calender.components(NSCalendarUnit.Month, fromDate: headache.date).month
            // Add the month as the dictionary key
            if !headachesForMonths.keys.contains(headacheMonth) {
                headachesForMonths[headacheMonth] = []
            }
            
            // Append the headache to the appropriate month
            if let h = headachesForMonths[headacheMonth] { // h = array of headaches
                if !h.contains(headache) {
                    headachesForMonths[headacheMonth]?.append(headache)
                }
            }
        }
    }
    
    private func loadHeadachesForPastMonth() {
        let calendar = NSCalendar.currentCalendar()
        
        if let oneMonthAgo = calendar.dateByAddingUnit(.Month, value: -1, toDate: NSDate(), options: []) {
            //print("one month ago: \(oneMonthAgo)")
            for headache in headaches {
//                print("headache date: \(headache.date)")
//                print(headache.date.compare(oneMonthAgo) == NSComparisonResult.OrderedDescending)
//                print(headache.date.compare(oneMonthAgo) == NSComparisonResult.OrderedSame)
                
                if (headache.date.compare(oneMonthAgo) == NSComparisonResult.OrderedDescending) ||
                    (headache.date.compare(oneMonthAgo) == NSComparisonResult.OrderedSame) {
                        headachesForPastMonth.append(headache)
                }
            }
        }

    }
    
}