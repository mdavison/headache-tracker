//
//  TestCoreDataStack.swift
//  Headaches
//
//  Created by Morgan Davison on 2/13/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

@testable import HeadacheTracker
import Foundation
import CoreData

class TestCoreDataStack: CoreDataStack {
    
    override init() {
        super.init()
        
        self.psc = {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            
            do {
                try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
            } catch {
                fatalError()
            }
            
            return persistentStoreCoordinator
        }()
    }
}
