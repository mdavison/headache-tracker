//
//  Headache.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 1/18/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit
import CoreData


class Headache: NSManagedObject {

    func severityDescription() -> String {
        let severityInt = Int(severity!)
        
        switch severityInt {
        case 1: return "❶"
        case 2: return "❷"
        case 3: return "❸"
        case 4: return "❹"
        case 5: return "❺"
        default: return ""
        }
    }
    
    func severityColor() -> [String: CGFloat] {
        let severityInt = Int(severity!)
        
        switch severityInt {
        case 1: return ["red": CGFloat(204.0/255.0), "green": 1.0, "blue": CGFloat(102.0/255.0)]
        case 2: return ["red": 1.0, "green": 1.0, "blue": CGFloat(102.0/255.0)]
        case 3: return ["red": 1.0, "green": CGFloat(204.0/255.0), "blue": CGFloat(102.0/255.0)]
        case 4: return ["red": 1.0, "green": CGFloat(128.0/255.0), "blue": 0]
        case 5: return ["red": 1.0, "green": 0, "blue": 0]
        default: return ["red": 0, "green": 0, "blue": 0]
        }
    }
    
    static func colorForSeverity(severity: Int) -> UIColor {
        switch severity {
        case 1: return UIColor(red: CGFloat(204.0/255.0), green: CGFloat(1.0), blue: CGFloat(102.0/255.0), alpha: 1)
        case 2: return UIColor(red: CGFloat(1.0), green: CGFloat(1.0), blue: CGFloat(102.0/255.0), alpha: 1)
        case 3: return UIColor(red: CGFloat(1.0), green: CGFloat(204.0/255.0), blue: CGFloat(102.0/255.0), alpha: 1)
        case 4: return UIColor(red: CGFloat(1.0), green: CGFloat(128.0/255.0), blue: CGFloat(102.0/255.0), alpha: 1)
        case 5: return UIColor(red: CGFloat(1.0), green: CGFloat(0), blue: CGFloat(0), alpha: 1)
        default: return UIColor(red: CGFloat(1.0), green: CGFloat(1.0), blue: CGFloat(1.0), alpha: 1)
        }
    }

}
