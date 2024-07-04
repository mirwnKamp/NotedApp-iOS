//
//  AlertPresentableVC+Generic.swift
//  MyNotes
//
//  Created by M-STAT Myron Kampourakis on 2/7/24.
//

import UIKit

extension AlertPresentableVC {
    
    func deleteAlert(title: String?, description: String?, actionAfterHide: @escaping ()->(), secondAction: @escaping ()->()) -> AlertVC {
        AlertVC(
            alertTitle:title ?? "",
            subtitle: description ?? "",
            mainButton: AlertButton(title: "Delete", actionAfterHide: actionAfterHide),
            secondaryButton: AlertButton(title: "Cancel", actionAfterHide: secondAction)
        )
    }
}
