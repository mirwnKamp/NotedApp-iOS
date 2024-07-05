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
    private let descriptionView: UITextView = {
        let descriptionView = UITextView.newAutoLayoutView()
        descriptionView.backgroundColor = UIColor.clear
        descriptionView.font = .systemFont(ofSize: 16)
        return descriptionView
    }()
    @IBOutlet weak var titleViewHeightConstraint: NSLayoutConstraint!
    private let drawView = DrawView.newAutoLayoutView()
    private var isDrawingEnabled = false
    private var drawViewHeightConstraint: NSLayoutConstraint!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView.newAutoLayoutView()
        scrollView.backgroundColor = UIColor.clear
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScrollView()
        NotificationCenter.default.addObserver(self, selector: #selector(titleViewContentSizeDidChange), name: UITextView.textDidChangeNotification, object: titleView)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollViewContentSizeDidChange), name: UITextView.textDidChangeNotification, object: descriptionView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func titleViewContentSizeDidChange() {
        let size = titleView.sizeThatFits(CGSize(width: titleView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        titleViewHeightConstraint.constant = size.height
        view.layoutIfNeeded()
    }
    
    @objc private func scrollViewContentSizeDidChange() {
        let descriptionSize = descriptionView.sizeThatFits(CGSize(width: descriptionView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let drawViewHeight = drawView.bounds.height
        let maxHeight = max(descriptionSize.height, drawViewHeight, UIScreen.main.bounds.height)
        
        drawViewHeightConstraint.constant = maxHeight
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: maxHeight)
        view.layoutIfNeeded()
    }
    
    // MARK: -SetupUI
    private func setupUI() {
        let backButtonImage = UIImage(systemName: "arrow.backward.circle.fill")
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
        let addButtonImage = UIImage(systemName: "paintpalette.fill")
        let addButton = UIBarButtonItem(image: addButtonImage, style: .plain, target: self, action: #selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem = addButton
        
        titleView.isScrollEnabled = false
        descriptionView.isScrollEnabled = false
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
    }
    
    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(descriptionView)
        scrollView.addSubview(drawView)
        let screenSize = UIScreen.main.bounds
        drawViewHeightConstraint = drawView.heightAnchor.constraint(equalToConstant: screenSize.height)
        drawViewHeightConstraint.isActive = true
        let descriptionSize = descriptionView.sizeThatFits(CGSize(width: descriptionView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let drawViewHeight = drawView.bounds.height
        let maxHeight = max(descriptionSize.height, drawViewHeight, UIScreen.main.bounds.height)
        
        drawViewHeightConstraint.constant = maxHeight
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: maxHeight)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            descriptionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            descriptionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            descriptionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            
            drawView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            drawView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            drawView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            drawView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            drawView.widthAnchor.constraint(equalToConstant: screenSize.width)
        ])

        drawView.canvasView.delegate = self
        descriptionView.delegate = self
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
        scrollView.isScrollEnabled = !isEnabled
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
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        drawView.toolPicker.setVisible(false, forFirstResponder: canvasView)
    }
    
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        drawView.toolPicker.setVisible(true, forFirstResponder: canvasView)
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
