//
//  AlertService+Home.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 15.04.26.
//

import Foundation

struct HomeAlertServiceUseCase: HomeAlertServiceUseCaseProtocol {

    let service: AlertService

    func showAlert(
        title: String,
        message: String,
        cancelTitle: String,
        cancelHandler: AlertActionHandler?,
        okTitle: String,
        okHandler: AlertActionHandler?
    ) {
        self.service.showAlert(
            title: title,
            message: message,
            cancelTitle: "Cancel",
            cancelHandler: cancelHandler,
            okTitle: okTitle,
            okHandler: okHandler
        )
    }

}
