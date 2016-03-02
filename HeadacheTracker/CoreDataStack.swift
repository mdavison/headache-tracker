//
//  CoreDataStack.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 1/18/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    let modelName = "Headache"
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var context: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = self.psc
        return managedObjectContext
    }()
    
    internal lazy var psc: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.modelName)
        
        do {
            let options =
                [NSMigratePersistentStoresAutomaticallyOption: true,
                NSPersistentStoreUbiquitousContentNameKey: "HeadacheTrackr",
                NSInferMappingModelAutomaticallyOption: true]
            
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch {
            print("Error adding persistent store.")
        }
        
        return coordinator
    }()
    
    internal lazy var managedObjectModel: NSManagedObjectModel = {
        
        let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    var updateContextWithUbiquitousContentUpdates: Bool = false {
        willSet {
            ubiquitousChangesObserver = newValue ? NSNotificationCenter.defaultCenter(): nil
        }
    }
    
    private var ubiquitousChangesObserver: NSNotificationCenter? {
        didSet{
            oldValue?.removeObserver(self, name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: psc)
            ubiquitousChangesObserver?.addObserver(self, selector: "persistentStoreDidImportUbiquitousContentChanges:", name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: psc)
        }
    }
    
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()                
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                abort()
            }
        }
    }
    
    @objc func persistentStoreDidImportUbiquitousContentChanges(notification: NSNotification) {
        NSLog("Merging ubiquitous content changes")
        context.performBlock { () -> Void in
            self.context.mergeChangesFromContextDidSaveNotification(notification)
        }
    }
    
}
