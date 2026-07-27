//
//  AlertService+Reset.swift
//  NetflixProject
//
//  Created by George Popkich on 7.04.26.
//

import Foundation

struct ResetAlertServiceUseCase: ResetAlertServiceUseCaseProtocol {

    private let service: AlertService

    init(service: AlertService) {
        self.service = service
    }

    func showAlert(
        title: String?,
        message: String?,
        cancelTitle: String?,
        cancelHandler: AlertActionHandler?,
        okTitle: String?
    ) {
        service.showAlert(
            title: title,
            message: message,
            cancelTitle: cancelTitle,
            cancelHandler: cancelHandler,
            okTitle: okTitle
        )
    }

}
