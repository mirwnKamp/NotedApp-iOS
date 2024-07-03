//
//  AlertPresentableVC.swift
//  MyNotes
//
//  Created by Myron Kampourakis on 2/7/24.
//

import UIKit

protocol AlertPresentableVC where Self: UIViewController {
    @discardableResult func presentAlert(_ alertType: AlertVC.AlertType) -> AlertVC
}
