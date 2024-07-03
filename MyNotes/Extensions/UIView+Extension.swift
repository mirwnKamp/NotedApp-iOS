//
//  UIView+Extension.swift
//  MyNotes
//
//  Created by Myron Kampourakis on 2/7/24.
//

import UIKit

extension UIView {
    
    func fillToSuperview(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: insets.bottom),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: insets.right)
        ])
    }
    
    static func newAutoLayoutView() -> Self {
        let view = Self()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }
    
    func fround(
        with cornerRadius: CGFloat,
        borderWidth: CGFloat = 0,
        color: UIColor = .clear
    ) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
        self.clipsToBounds = true
    }
    
}
