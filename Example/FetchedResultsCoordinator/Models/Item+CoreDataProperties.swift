//
//  Item+CoreDataProperties.swift
//  
//
//  Created by Mark Carter on 29/11/2015.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Item {

    @NSManaged var hidden: NSNumber?
    @NSManaged var section: String?
    @NSManaged var name: String?
    @NSManaged var ordinal: NSNumber?

}
