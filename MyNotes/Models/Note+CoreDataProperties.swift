//
//  Note+CoreDataProperties.swift
//  MyNotes
//
//  Created by M-STAT S.A. IT on 13/5/24.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var id: UUID!
    @NSManaged public var title: String!
    @NSManaged public var desc: String!
    @NSManaged public var lastUpdated: Date!

}

extension Note : Identifiable {

}
