//
//  Entity+CoreDataClass.swift
//  MyNotes
//
//  Created by M-STAT S.A. IT on 13/5/24.
//
//

import Foundation
import CoreData

@objc(Entity)
public class Entity: NSManagedObject {
    var title: String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines).first ?? "" // returns the first line of the text
    }
    
    var desc: String {
        var lines = text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
        lines.removeFirst()
        return "\(lastUpdated.format()) \(lines.first ?? "")" // return second line
    }
}
