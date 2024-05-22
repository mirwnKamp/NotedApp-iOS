//
//  Note+CoreDataClass.swift
//  MyNotes
//
//  Created by M-STAT S.A. IT on 13/5/24.
//
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {
    
    var titleNote: String {
        return title ?? ""
    }
    
    var descNote: String {
        return desc ?? ""
    }
    
    var dateNote: String {
        return "\(lastUpdated.format())"
    }
}
