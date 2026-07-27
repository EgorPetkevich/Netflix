//
//  AlertService.swift
//  NetflixProject
//
//  Created by George Popkich on 31.03.26.
//

import UIKit

final class AlertService {

    typealias AlertActionHandler = () -> Void

    private let windowManager: WindowManager

    init(container: Container) {
        self.windowManager = container.resolve()
    }

    func showAlert(
        title: String?,
        message: String?,
        cancelTitle: String? = nil,
        cancelHandler: AlertActionHandler? = nil,
        okTitle: String? = nil,
        okHandler: AlertActionHandler? = nil
    ) {
        let alertVC = buildAlert(
            title: title,
            message: message,
            cancelTitle: cancelTitle,
            cancelHandler: cancelHandler,
            okTitle: okTitle,
            okHandler: okHandler
        )

        let window = windowManager.get(type: .alert)
        window.rootViewController = UIViewController()
        windowManager.show(type: .alert)
        window.rootViewController?.present(alertVC, animated: true)
    }

    private func buildAlert(
        title: String?,
        message: String?,
        cancelTitle: String? = nil,
        cancelHandler: AlertActionHandler? = nil,
        okTitle: String? = nil,
        okHandler: AlertActionHandler? = nil
    ) -> UIAlertController {

        let alertVC = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        if let cancelTitle {
            let action = buildAction(
                with: cancelTitle,
                style: .cancel,
                handler: cancelHandler
            )
            alertVC.addAction(action)
        }

        if let okTitle {
            let action = buildAction(
                with: okTitle,
                style: .default,
                handler: okHandler
            )
            alertVC.addAction(action)
        }

        return alertVC
    }

    private func buildAction(
        with title: String?,
        style: UIAlertAction.Style,
        handler: AlertActionHandler?
    ) -> UIAlertAction {
        return UIAlertAction(
            title: title,
            style: style
        ) { [weak self] _ in
            handler?()
            self?.windowManager.hideAndRemove(type: .alert)
        }
    }

}
