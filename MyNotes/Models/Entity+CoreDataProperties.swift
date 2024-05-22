//
//  Entity+CoreDataProperties.swift
//  MyNotes
//
//  Created by M-STAT S.A. IT on 13/5/24.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var text: String?
    @NSManaged public var lastUpdated: Date?

}

extension Entity : Identifiable {

}
