//
//  Medication+CoreDataProperties.swift
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

extension Medication {

    @NSManaged var displayOrder: NSNumber?
    @NSManaged var name: String?
    //@NSManaged var headaches: NSSet?
    @NSManaged var headaches: Set<Headache>?
    //@NSManaged var doses: NSSet?
    @NSManaged var doses: Set<Medication>?

}
