//
//  Headache.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/10/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import UIKit

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
        case 1: return "❶"
        case 2: return "❷"
        case 3: return "❸"
        case 4: return "❹"
        case 5: return "❺"
        default: return ""
        }
    }
    
    func severityColor() -> [String: CGFloat] {
        switch severity {
        case 1: return ["red": CGFloat(204.0/255.0), "green": 1.0, "blue": CGFloat(102.0/255.0)]
        case 2: return ["red": 1.0, "green": 1.0, "blue": CGFloat(102.0/255.0)]
        case 3: return ["red": 1.0, "green": CGFloat(204.0/255.0), "blue": CGFloat(102.0/255.0)]
        case 4: return ["red": 1.0, "green": CGFloat(128.0/255.0), "blue": 0]
        case 5: return ["red": 1.0, "green": 0, "blue": 0]
        default: return ["red": 0, "green": 0, "blue": 0]
        }
    }

}