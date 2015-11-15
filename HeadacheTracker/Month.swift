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

    init(headaches: [Headache]) {
        self.headaches = headaches
        loadHeadachesForMonths()
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
    
}