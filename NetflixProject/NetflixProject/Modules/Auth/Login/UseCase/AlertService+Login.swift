//
//  AlertService+Login.swift
//  NetflixProject
//
//  Created by George Popkich on 31.03.26.
//

import Foundation

struct LoginAlertServiceUseCase: LoginAlertServiceUseCaseProtocol {

    let service: AlertService

    func showAlert(
        title: String?,
        message: String?,
        cancelTitle: String?,
        cancelHandler: AlertActionHandler?,
        okTitle: String?
    ) {
        self.service.showAlert(
            title: title,
            message: message,
            cancelTitle: cancelTitle,
            cancelHandler: cancelHandler,
            okTitle: okTitle
        )
    }

}
