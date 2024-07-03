//
//  AlertVC.swift
//  MyNotes
//
//  Created by Myron Kampourakis on 2/7/24.
//

import UIKit

typealias AlertButton = AlertVC.AlertButton

class AlertVC: UIViewController {
    var backgroundWhiteView: UIView = {
        let backgroundWhiteView = UIView.newAutoLayoutView()
        backgroundWhiteView.backgroundColor = UIColor.white
        backgroundWhiteView.layer.cornerRadius = 20

        return backgroundWhiteView
    }()

    var contentStackView: UIStackView = {
        let contentStackView = UIStackView.newAutoLayoutView()
        contentStackView.axis = .vertical
        contentStackView.distribution = .equalSpacing
        contentStackView.alignment = .center
        contentStackView.spacing = 25

        return contentStackView
    }()

    var titleLabel: UILabel = {
        let titleLabel = UILabel.newAutoLayoutView()
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .textColor
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        return titleLabel
    }()

    var subTitleLabel: UILabel = {
        let subTitleLabel = UILabel.newAutoLayoutView()
        subTitleLabel.font = .systemFont(ofSize: 16)
        subTitleLabel.textColor = .textColor
        subTitleLabel.numberOfLines = 0
        subTitleLabel.textAlignment = .center

        return subTitleLabel
    }()
    
    var selectionStackView: UIStackView = {
        let selectionStackView = UIStackView.newAutoLayoutView()
        selectionStackView.axis = .vertical
        selectionStackView.distribution = .fill
        selectionStackView.alignment = .leading
        selectionStackView.spacing = 25
        
        return selectionStackView
    }()

    var buttonsView: UIView = {
        let buttonsView = UIView.newAutoLayoutView()
        buttonsView.backgroundColor = .clear

        return buttonsView
    }()

    var mainCommonButton: UIButton = {
        let mainCommonButton = UIButton.newAutoLayoutView()
        mainCommonButton.fround(with: 15, borderWidth: 1, color: UIColor.red)
        mainCommonButton.backgroundColor = UIColor.red
        mainCommonButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        mainCommonButton.setTitleColor(.white, for: .normal)
        mainCommonButton.isEnabled = true
        return mainCommonButton
    }()

    var secondaryCommonButton: UIButton = {
        let secondaryCommonButton = UIButton.newAutoLayoutView()
        secondaryCommonButton.titleLabel?.font = .systemFont(ofSize:16)
        secondaryCommonButton.setTitleColor(.textColor, for: .normal)
        secondaryCommonButton.isEnabled = true
        return secondaryCommonButton
    }()
    
    var selectedOption: String?

    struct AlertButton {
        let title: String
        let hideAfterAction: Bool
        let action: (() -> ())?
        let actionAfterHide: (() -> ())?
        let actionAfterHideWithString: ((String) -> ())?

        init(
            title: String,
            hideAfterAction: Bool = true,
            action: (() -> ())? = nil,
            actionAfterHide: (() -> ())? = nil,
            actionAfterHideWithString: ((String) -> ())? = nil
        ) {
            self.title = title
            self.hideAfterAction = hideAfterAction
            self.action = action
            self.actionAfterHide = actionAfterHide
            self.actionAfterHideWithString = actionAfterHideWithString
        }
    }

    let alertTitle: String
    let subtitle: String?
    let mainButton: AlertButton
    let secondaryButton: AlertButton?
    let optionsArray: [String]?

    required init(
        alertTitle: String,
        subtitle: String? = nil,
        mainButton: AlertButton,
        secondaryButton: AlertButton? = nil,
        optionsArray: [String]? = nil
    ) {
        self.alertTitle = alertTitle
        self.subtitle = subtitle
        self.mainButton = mainButton
        self.secondaryButton = secondaryButton
        self.optionsArray = optionsArray

        super.init(nibName: nil, bundle: nil)

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc func mainButtonAction() {
        if let action = mainButton.action {
            action()
        }
        if mainButton.hideAfterAction {
            if let actionAfterHideWithString = mainButton.actionAfterHideWithString,
               let selectedButton = selectionStackView
                .arrangedSubviews
                .compactMap({ $0 as? UIButton })
                .first(where: { $0.isEnabled == true }),
               let option = selectedButton.title(for: .normal), selectedOption == nil {
                //first option
                self.dismiss(animated: true) {
                    actionAfterHideWithString(option)
                }
            } else if let actionAfterHideWithString = mainButton.actionAfterHideWithString,
                      let selectedOption = selectedOption {
                //another option selected
                self.dismiss(animated: true) {
                    actionAfterHideWithString(selectedOption)
                }
            }
            self.dismiss(animated: true, completion: mainButton.actionAfterHide)
        }
    }

    @objc func secondaryButtonAction() {
        guard let secondaryButton = secondaryButton else { return }
        if let action = secondaryButton.action {
            action()
        }
        if secondaryButton.hideAfterAction {
            self.dismiss(animated: true, completion: secondaryButton.actionAfterHide)
        }
    }
    
    @objc func selectOption(_ sender: UIButton) {
        selectedOption = sender.title(for: .normal)
        selectionStackView
            .arrangedSubviews
            .compactMap({ $0 as? UIButton })
            .forEach { button in
                button.isSelected = button == sender
            }
    }
}

// MARK: - UI Elements
private extension AlertVC {
    func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        addBackgroundWhiteView()
        addContentStackView()
        addTitleLabel()

        if let subtitle = subtitle {
            addSubTitleLabel(text: subtitle)
        }
        if let optionsArray = optionsArray, optionsArray.count > 0 {
            addOptionViews(optionsArray)
        }
        addButtonsView()
        
        addMainButton()
        if let secondaryButton = secondaryButton {
            addSecondaryButton(button: secondaryButton)
        } else {
            mainCommonButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor).isActive = true
        }
    }

    func addBackgroundWhiteView() {
        view.addSubview(backgroundWhiteView)
        backgroundWhiteView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        backgroundWhiteView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 27).isActive = true
        backgroundWhiteView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -27).isActive = true
        backgroundWhiteView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        backgroundWhiteView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
    }

    func addContentStackView() {
        backgroundWhiteView.addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: backgroundWhiteView.leadingAnchor, constant: 15).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: backgroundWhiteView.trailingAnchor, constant: -15).isActive = true
        contentStackView.topAnchor.constraint(equalTo: backgroundWhiteView.topAnchor, constant: 40).isActive = true
    }

    func addTitleLabel() {
        titleLabel.text = alertTitle
        contentStackView.addArrangedSubview(titleLabel)
    }

    func addSubTitleLabel(text: String) {
        subTitleLabel.text = text
        contentStackView.addArrangedSubview(subTitleLabel)
    }
    
    func addOptionViews(_ optionsArray: [String]?) {
        guard let optionsArray = optionsArray, !optionsArray.isEmpty else {
            return
        }
        
        contentStackView.addArrangedSubview(selectionStackView)
        selectionStackView.translatesAutoresizingMaskIntoConstraints = false
        selectionStackView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor).isActive = true
        optionsArray.forEach { selection in
            let selectionButton = UIButton.newAutoLayoutView()
            selectionButton.setImage(UIImage(named: "selected_radio_btn"), for: .selected)
            selectionButton.setImage(UIImage(named: "unselected_radio_btn"), for: .normal)
            selectionButton.isSelected = selectionStackView.arrangedSubviews.isEmpty
            selectionButton.titleLabel?.font = .systemFont(ofSize: 16)
            selectionButton.setTitleColor(.black, for: .normal)
            selectionButton.addTarget(self, action: #selector(Self.selectOption(_:)), for: .touchUpInside)
            selectionButton.setTitle(selection, for: .normal)
            selectionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -21)
            selectionStackView.addArrangedSubview(selectionButton)
        }
    }

    func addButtonsView() {
        backgroundWhiteView.addSubview(buttonsView)
        buttonsView.topAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: 30).isActive = true
        buttonsView.bottomAnchor.constraint(equalTo: backgroundWhiteView.bottomAnchor, constant: -40).isActive = true
        buttonsView.leadingAnchor.constraint(equalTo: backgroundWhiteView.leadingAnchor, constant: 90).isActive = true
        buttonsView.trailingAnchor.constraint(equalTo: backgroundWhiteView.trailingAnchor, constant: -90).isActive = true
    }

    func addMainButton() {
        mainCommonButton.setTitle(mainButton.title, for: .normal)
        mainCommonButton.titleLabel?.numberOfLines = 0
        mainCommonButton.titleLabel?.textAlignment = .center
        mainCommonButton.addTarget(self, action: #selector(Self.mainButtonAction), for: .touchUpInside)
        buttonsView.addSubview(mainCommonButton)
        
        NSLayoutConstraint.activate([
            mainCommonButton.topAnchor.constraint(equalTo: buttonsView.topAnchor),
            mainCommonButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor),
            mainCommonButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor)
        ])
    }

    func addSecondaryButton(button: AlertButton) {
        secondaryCommonButton.setTitle(button.title, for: .normal)
        secondaryCommonButton.addTarget(self, action: #selector(Self.secondaryButtonAction), for: .touchUpInside)
        buttonsView.addSubview(secondaryCommonButton)
        
        
        NSLayoutConstraint.activate([
            secondaryCommonButton.topAnchor.constraint(equalTo: mainCommonButton.bottomAnchor, constant: 11),
            secondaryCommonButton.centerXAnchor.constraint(equalTo: mainCommonButton.centerXAnchor),
            secondaryCommonButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor)
        ])
    }
}

private extension UIColor {
    static let textColor = UIColor(named: "alertTextColor") ?? .black
}


