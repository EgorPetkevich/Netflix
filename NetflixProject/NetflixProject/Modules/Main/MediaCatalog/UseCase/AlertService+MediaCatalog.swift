//
//  AlertService+MediaCatalog.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 13.05.26.
//

import Foundation

struct MediaCatalogAlertServiceUseCase: MediaCatalogAlertServiceUseCaseProtocol {

    let service: AlertService

    func showAlert(
        title: String?,
        message: String?,
        cancelHandler: AlertActionHandler?,
        okTitle: String?
    ) {
        self.service.showAlert(
            title: title,
            message: message,
            cancelTitle: "Cancel",
            cancelHandler: cancelHandler,
            okTitle: okTitle
        )
    }

}
