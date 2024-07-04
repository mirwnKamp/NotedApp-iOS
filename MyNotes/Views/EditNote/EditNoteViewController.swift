//
//  EditNoteViewController.swift
//  MyNotes
//
//  Created by Myron Kampourakis on 13/5/24.
//

import UIKit

class EditNoteViewController: UIViewController {
    
    static let identifier = "EditNoteViewController"
    var note: Note!
    
    @IBOutlet weak private var titleView: UITextView!
    @IBOutlet weak private var descriptionView: UITextView!
    @IBOutlet weak var titleViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(titleViewContentSizeDidChange), name: UITextView.textDidChangeNotification, object: titleView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func titleViewContentSizeDidChange() {
        let size = titleView.sizeThatFits(CGSize(width: titleView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        titleViewHeightConstraint.constant = size.height
        view.layoutIfNeeded()
    }
    
    // MARK: -SetupUI
    private func setupUI() {
        let backButtonImage = UIImage(systemName: "arrow.backward.circle.fill")
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
        
        titleView.isScrollEnabled = false
        titleView.text = note?.titleNote
        descriptionView.text = note?.descNote
        if titleView.text.isEmpty {
            titleView.text = "Title"
            titleView.textColor = .lightGray
        } else {
            let size = titleView.sizeThatFits(CGSize(width: titleView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            titleViewHeightConstraint.constant = size.height
        }
        if descriptionView.text.isEmpty {
            descriptionView.text = "Note"
            descriptionView.textColor = .lightGray
        }
        
        titleView.delegate = self
        descriptionView.delegate = self
    }
    
    @objc func backButtonTapped() {
        if (note?.title?.isEmpty ?? true) && (note?.desc?.isEmpty ?? true) {
            deleteNote()
        } else {
            updateNote()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: -Methods to implement
    private func updateNote() {
        note.lastUpdated = Date()
        CoreDataManager.shared.save()
    }
    
    private func deleteNote() {
        CoreDataManager.shared.deleteNote(note)
    }
}

// MARK: -UITextView Delegate
extension EditNoteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView == titleView {
            note?.title = textView.text
        } else if textView == descriptionView {
            note?.desc = textView.text
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == descriptionView && textView.text.isEmpty {
            descriptionView.text = "Note"
            descriptionView.textColor = .lightGray
        } else if textView == titleView && textView.text.isEmpty {
            titleView.text = "Title"
            titleView.textColor = .lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
}
