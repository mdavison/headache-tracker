//
//  Week.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/13/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import Foundation

class Week {
    
    var number = 0
    var headaches = [Headache]() // this gets ALL headaches, not just headaches for this week
    var headachesForWeeks = [Int: [Headache]]()
    var headachesForPastWeek = [Headache]()
    
    init(headaches: [Headache]) {
        self.headaches = headaches
        loadHeadachesForWeeks()
        loadHeadachesForPastWeek()
    }
    
    private func loadHeadachesForWeeks() {
        let calender = NSCalendar.currentCalendar()
        
        for headache in headaches {
            let headacheWeek = calender.components(NSCalendarUnit.WeekOfYear, fromDate: headache.date!).weekOfYear
            // Add the week as the dictionary key
            if !headachesForWeeks.keys.contains(headacheWeek) {
                headachesForWeeks[headacheWeek] = []
            }
            
            // Append the headache to the appropriate week
            if let h = headachesForWeeks[headacheWeek] { // h = array of headaches
                if !h.contains(headache) {
                    headachesForWeeks[headacheWeek]?.append(headache)
                }
            }
        }
    }
    
    private func loadHeadachesForPastWeek() {
        let calendar = NSCalendar.currentCalendar()
        
        if let oneWeekAgo = calendar.dateByAddingUnit(.Day, value: -7, toDate: NSDate(), options: []) {
            //print("one week ago: \(oneWeekAgo)")
            for headache in headaches {
                //print("headache date: \(headache.date)")
                //print(headache.date.compare(oneWeekAgo) == NSComparisonResult.OrderedDescending)
                //print(headache.date.compare(oneWeekAgo) == NSComparisonResult.OrderedSame)
                
                if (headache.date!.compare(oneWeekAgo) == NSComparisonResult.OrderedDescending) ||
                    (headache.date!.compare(oneWeekAgo) == NSComparisonResult.OrderedSame) {
                    headachesForPastWeek.append(headache)
                }            
            }
        }
    }
    
}
