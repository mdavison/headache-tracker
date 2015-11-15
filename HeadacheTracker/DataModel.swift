//
//  DataModel.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/11/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import Foundation

class DataModel {
    
    var headaches = [Headache]()
    
    init() {
        loadHeadaches()
    }
    
    func saveHeadaches() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(headaches, forKey: "Headaches")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    
    private func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        return paths[0]
    }
    
    private func dataFilePath() -> String {
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("HeadacheTracker.plist")
    }
    
    private func loadHeadaches() {
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                headaches = unarchiver.decodeObjectForKey("Headaches") as! [Headache]
                headaches.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending })
                unarchiver.finishDecoding()
            }
        }
    }
    
}