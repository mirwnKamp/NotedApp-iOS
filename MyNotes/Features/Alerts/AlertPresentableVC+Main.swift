//
//  AlertPresentableVC+Main.swift
//  MyNotes
//
//  Created by Myron Kampourakis on 2/7/24.
//

extension AlertPresentableVC {
    @discardableResult func presentAlert(_ alertType: AlertVC.AlertType) -> AlertVC {
        var alert: AlertVC!

        switch alertType {
        case .deleteAlert(let t, let d, let a, let b): alert = deleteAlert(title: t, description: d, actionAfterHide: a, secondAction: b)
        }

        alert.modalPresentationStyle = .overFullScreen
        present(alert, animated: true)

        return alert
    }
}
