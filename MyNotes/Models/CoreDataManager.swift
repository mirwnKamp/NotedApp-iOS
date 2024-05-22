//
//  CoreDataManager.swift
//  MyNotes
//
//  Created by M-STAT S.A. IT on 13/5/24.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager(modelName: "MyNotes")
    
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores {
            (description, error) in
            guard error == nil else { fatalError(error!.localizedDescription) }
            completion?()
        }
    }
    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("An error occured while saving: \(error.localizedDescription)")
            }
        }
    }
}

extension CoreDataManager {
    func createNote() -> Note {
        let note = Note(context: CoreDataManager.shared.viewContext)
        note.id = UUID()
        note.title = ""
        note.desc = ""
        note.lastUpdated = Date()
        save()
        
        return note
    }
    
    func fetchNotes(filter: String? = nil) -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Note.lastUpdated, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        if let filter = filter {
            let predicate = NSPredicate(format: "title contains[cd] %@", filter)
            request.predicate = predicate
        }
        return (try? viewContext.fetch(request)) ?? []
    }
    
    func deleteNote(_ note: Note) {
        viewContext.delete(note)
        save()
    }
    
    func createNotesFetchedResultsController(filter: String? = nil) -> NSFetchedResultsController<Note> {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Note.lastUpdated, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        if let filter = filter {
            let predicate = NSPredicate(format: "title contains[cd] %@", filter)
            request.predicate = predicate
        }
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
}
