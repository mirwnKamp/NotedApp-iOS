//
//  Note+CoreDataProperties.swift
//  MyNotes
//
//  Created by Myron Kampourakis on 23/5/24.
//

import Foundation
import CoreData

extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var desc: String!
    @NSManaged public var id: UUID!
    @NSManaged public var lastUpdated: Date!
    @NSManaged public var title: String!

}

extension Note : Identifiable {

}
