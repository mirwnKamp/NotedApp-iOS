//
//  AlertVC+Main.swift
//  MyNotes
//
//  Created by Myron Kampourakis on 2/7/24.
//

import UIKit

extension AlertVC {
    enum AlertType {
        case deleteAlert(title: String?, description: String?, actionAfterHide: ()->(), secondAction: ()->())
    }
}
