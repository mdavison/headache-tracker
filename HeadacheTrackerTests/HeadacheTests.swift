//
//  HeadacheTests.swift
//  Headaches
//
//  Created by Morgan Davison on 2/13/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import XCTest
@testable import HeadacheTracker
import CoreData

class HeadacheTests: XCTestCase {
    
    var headache: Headache!
    var coreDataStack: CoreDataStack!

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        coreDataStack = TestCoreDataStack()
        let headacheEntity = NSEntityDescription.entityForName("Headache", inManagedObjectContext: coreDataStack.context)
        headache = Headache(entity: headacheEntity!, insertIntoManagedObjectContext: coreDataStack.context)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        coreDataStack = nil 
    }

//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    func testSeverityDescription() {
        headache.severity = 2
        
        XCTAssertTrue(headache.severityDescription() == "❷")
    }
    
    func testSeverityColor() {
        headache.severity = 2
        
        XCTAssertTrue(headache.severityColor() == ["red": 1.0, "green": 1.0, "blue": CGFloat(102.0/255.0)])
    }
    
    func testColorForSeverity() {
        let color = Headache.colorForSeverity(2)
        
        XCTAssertTrue(color == UIColor(red: CGFloat(1.0), green: CGFloat(1.0), blue: CGFloat(102.0/255.0), alpha: 1))
    }

}
