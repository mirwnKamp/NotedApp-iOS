//
//  EditNoteViewController.swift
//  MyNotes
//
//  Created by Myron Kampourakis on 13/5/24.
//

import UIKit
import PencilKit

class EditNoteViewController: UIViewController, PKCanvasViewDelegate {
    
    static let identifier = "EditNoteViewController"
    var note: Note!
    
    @IBOutlet weak private var titleView: UITextView!
    @IBOutlet weak private var descriptionView: UITextView!
    @IBOutlet weak var titleViewHeightConstraint: NSLayoutConstraint!
    private let drawView = DrawView.newAutoLayoutView()
    private var isDrawingEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        drawView.canvasView.delegate = self
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
        let addButtonImage = UIImage(systemName: "cross.circle.fill")
        let addButton = UIBarButtonItem(image: addButtonImage, style: .plain, target: self, action: #selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem = addButton
        
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
        if let drawingData = note?.canvasData, let drawing = try? PKDrawing(data: drawingData) {
            drawView.canvasView.drawing = drawing
        } else {
            drawView.canvasView.drawing = PKDrawing()
        }

        
        titleView.delegate = self
        descriptionView.delegate = self
        
        view.addSubview(drawView)
        drawView.fillToSuperview()
    
        toggleDrawing(isEnabled: false)
    }
    
    @objc func backButtonTapped() {
        if (note?.title?.isEmpty ?? true) && (note?.desc?.isEmpty ?? true) {
            deleteNote()
        } else {
            updateNote()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc  func addButtonTapped() {
        isDrawingEnabled.toggle()
        toggleDrawing(isEnabled: isDrawingEnabled)
    }
    
    private func toggleDrawing(isEnabled: Bool) {
        titleView.isUserInteractionEnabled = !isEnabled
        descriptionView.isUserInteractionEnabled = !isEnabled
        drawView.toolPicker.setVisible(isEnabled, forFirstResponder: drawView.canvasView)
        drawView.toolPicker.addObserver(drawView.canvasView)
        drawView.canvasView.becomeFirstResponder()
        drawView.isUserInteractionEnabled = isEnabled
    }
    
    // MARK: -Methods to implement
    private func updateNote() {
        note.lastUpdated = Date()
        CoreDataManager.shared.save()
    }
    
    private func deleteNote() {
        CoreDataManager.shared.deleteNote(note)
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        note.canvasData = canvasView.drawing.dataRepresentation()
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
