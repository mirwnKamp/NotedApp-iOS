//
//  DrawingView.swift
//  MyNotes
//
//  Created by Myron Kampourakis on 4/7/24.
//

import UIKit
import PencilKit

class DrawView: UIView, PKCanvasViewDelegate {
    
    let canvasView: PKCanvasView = {
        let canvasView = PKCanvasView.newAutoLayoutView()
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        return canvasView
    }()
    
    let toolPicker: PKToolPicker = {
        let toolPicker = PKToolPicker()
        return toolPicker
    }()
    
    var drawing = PKDrawing()
    var canvasHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        canvasView.drawing = drawing
        addSubview(canvasView)
        canvasView.fillToSuperview()
    }
}
