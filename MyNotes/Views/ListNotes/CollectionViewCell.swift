//
//  CollectionViewCell.swift
//  MyNotes
//
//  Created by Myron Kampourakis on 24/5/24.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    static let identifier = "NoteCollectionViewCell"
    
    private let titleLbl: UILabel = {
        let titleView = UILabel.newAutoLayoutView()
        titleView.numberOfLines = 1
        titleView.lineBreakMode = .byTruncatingTail
        return titleView
    }()
    
    private let descriptionText: UITextView = {
        let descriptionLbl = UITextView.newAutoLayoutView()
        descriptionLbl.isEditable = false
        descriptionLbl.isUserInteractionEnabled = false
        return descriptionLbl
    }()
    
    private let contentViewCell: UIView = {
        let contentViewCell = UIView.newAutoLayoutView()
        contentViewCell.clipsToBounds = false
        contentViewCell.fround(with: 15, borderWidth: 1, color: UIColor.black)
        contentViewCell.backgroundColor = .white
        
        return contentViewCell
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(contentViewCell)
        contentViewCell.addSubview(titleLbl)
        contentViewCell.addSubview(descriptionText)
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            contentViewCell.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentViewCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentViewCell.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentViewCell.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Constraints for titleLbl
            titleLbl.topAnchor.constraint(equalTo: contentViewCell.topAnchor, constant: 10),
            titleLbl.leadingAnchor.constraint(equalTo: contentViewCell.leadingAnchor, constant: 10),
            titleLbl.trailingAnchor.constraint(equalTo: contentViewCell.trailingAnchor, constant: -10),
            
            // Constraints for descriptionLbl
            descriptionText.bottomAnchor.constraint(equalTo: contentViewCell.bottomAnchor, constant: -10),
            descriptionText.leadingAnchor.constraint(equalTo: contentViewCell.leadingAnchor, constant: 10),
            descriptionText.trailingAnchor.constraint(equalTo: contentViewCell.trailingAnchor, constant: -10),
            descriptionText.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 10)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLbl.text = nil
        descriptionText.text = nil
    }
    
    func setup(note: Note) {
        titleLbl.text = note.title
        descriptionText.text = "\(note.dateNote)  \(note.desc ?? "")"
    }
}
