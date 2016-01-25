//
//  Month+CoreDataProperties.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 1/21/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Month {

    @NSManaged var name: String?
    @NSManaged var number: NSNumber?
    @NSManaged var headaches: NSOrderedSet?

}
