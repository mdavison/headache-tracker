//
//  Headache+CoreDataProperties.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 2/7/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Headache {

    @NSManaged var date: NSDate?
    @NSManaged var severity: NSNumber?
    @NSManaged var medications: Set<Medication>?
    @NSManaged var year: Year?
    @NSManaged var doses: Set<Dose>?

}
