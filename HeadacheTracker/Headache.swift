//
//  Headache.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/10/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import Foundation

class Headache: NSObject, NSCoding {
    
    var date = NSDate()
    var severity = 0
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        date = aDecoder.decodeObjectForKey("Date") as! NSDate
        severity = aDecoder.decodeIntegerForKey("Severity")
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(date, forKey: "Date")
        aCoder.encodeInteger(severity, forKey: "Severity")
    }
    
    func severityDescription() -> String {
        switch severity {
        case 1: return "Mild"
        case 2: return "Mild-Moderate"
        case 3: return "Moderate"
        case 4: return "Moderate-Severe"
        case 5: return "Severe"
        default: return ""
        }
    }

}