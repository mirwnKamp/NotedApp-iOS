//
//  ListNotesViewController.swift
//  MyNotes
//
//  Created Myron Kampourakis on 13/5/24.
//

import UIKit
import CoreData
import CHTCollectionViewWaterfallLayout

class ListNotesViewController: UIViewController, AlertPresentableVC {
    
    private let collectionView: UICollectionView = {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.itemRenderDirection = .shortestFirst
        layout.columnCount = 2
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: 0, left: 8, bottom: 8, right: 8)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak private var notesCountLbl: UILabel!
    private let searchController = UISearchController()
    private var fetchedResultsController: NSFetchedResultsController<Note>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        view.addSubview(collectionView)
        view.sendSubviewToBack(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        configureSearchBar()
        setupFetchedResultController()
        refreshCountLbl()
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])
    }
    
    func refreshCountLbl() {
        let count = fetchedResultsController.sections![0].numberOfObjects
        notesCountLbl.text = "\(String(describing: count)) \(count == 1 ? "Note" : "Notes")"
    }
    func setupFetchedResultController(filter: String? = nil) {
        fetchedResultsController = CoreDataManager.shared.createNotesFetchedResultsController(filter: filter)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        refreshCountLbl()
    }
    
    private func configureSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.delegate = self
    }
    
    @IBAction func createNewNoteClicked(_ sender: UIButton) {
        goToEditNote(createNote())
    }
    
    private func goToEditNote(_ note: Note) {
        let controller = storyboard?.instantiateViewController(identifier: EditNoteViewController.identifier) as! EditNoteViewController
        controller.note = note
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: -Methods to implement
    private func createNote() -> Note {
        let note = CoreDataManager.shared.createNote()
        return note
    }
    
    private func deleteNoteFromStorage(_ note: Note) {
        CoreDataManager.shared.deleteNote(note)
        try? fetchedResultsController.performFetch()
        collectionView.reloadData()
        refreshCountLbl()
    }
}


// MARK: -CollectionView Configuration
extension ListNotesViewController: UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let notes = fetchedResultsController.sections![section]
        return notes.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        let note = fetchedResultsController.object(at: indexPath)
        cell.setup(note: note)
        
        // Add long press gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressGesture)
        
        return cell
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        if let cell = gesture.view as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: cell) {
            let note = fetchedResultsController.object(at: indexPath)
            
            cell.fround(with: 15, borderWidth: 1, color: UIColor.red)
            
            self.presentAlert(.deleteAlert(title: "Delete Note", description: "Are you sure you want to delete this note?", actionAfterHide: {
                self.deleteNoteFromStorage(note)
                cell.fround(with: 15, borderWidth: 0, color: UIColor.clear)
            }, secondAction: {
                cell.fround(with: 15, borderWidth: 0, color: UIColor.clear)
            }))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let note = fetchedResultsController.object(at: indexPath)
        
        let width = view.frame.width / 2
        
        let horizontalPadding: CGFloat = 20.0
        
        let titleHeight = 20.0 // Default height for only line text at the cell
        let descHeight = calculateHeightForText("\(String(describing: note.lastUpdated))" + note.desc, width: width)
        let height = descHeight + titleHeight
        
        switch height {
        case ..<80 :
            return CGSize(width: width, height: height + horizontalPadding)
        case 80...199:
            return CGSize(width: width, height: height + horizontalPadding * 2)
        case 500...799:
            return CGSize(width: width, height: height - height/8)
        case 800...:
            return CGSize(width: width, height: height - height/6)
        default:
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let note = fetchedResultsController.object(at: indexPath)
        goToEditNote(note)
    }
    
    func calculateHeightForText(_ text: String, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 16)], context: nil)
        
        return ceil(boundingBox.height)
    }
    
}

// MARK: -Search Controller Configuration
extension ListNotesViewController: UISearchControllerDelegate, UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search("")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(searchBar.text ?? "")
    }
    
    func search(_ query: String) {
        if query.count >= 1 {
            setupFetchedResultController(filter: query)
        } else{
            setupFetchedResultController()
        }
        
        collectionView.reloadData()
    }
}

// MARK: -NSFetchResultController Delegate
extension ListNotesViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates(nil, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                collectionView.insertItems(at: [newIndexPath])
            }
        case .delete:
            if let indexPath = indexPath {
                collectionView.deleteItems(at: [indexPath])
            }
        case .update:
            if let indexPath = indexPath {
                collectionView.reloadItems(at: [indexPath])
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                collectionView.moveItem(at: indexPath, to: newIndexPath)
            }
        @unknown default:
            collectionView.reloadData()
        }
        refreshCountLbl()
    }
}
