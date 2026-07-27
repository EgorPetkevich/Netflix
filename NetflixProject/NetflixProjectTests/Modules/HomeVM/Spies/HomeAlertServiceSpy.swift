//
//  HomeAlertServiceSpy.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 18.06.26.
//

import Foundation
@testable import NetflixProject

final class HomeAlertServiceSpy: HomeAlertServiceUseCaseProtocol {

    private(set) var didShowAlert = false
    private(set) var showAlertCallCount = 0

    private(set) var receivedTitle: String?
    private(set) var receivedMessage: String?
    private(set) var receivedCancelTitle: String?
    private(set) var receivedOkTitle: String?

    private(set) var cancelHandler: AlertActionHandler?
    private(set) var okHandler: AlertActionHandler?

    func showAlert(
        title: String,
        message: String,
        cancelTitle: String,
        cancelHandler: AlertActionHandler?,
        okTitle: String,
        okHandler: AlertActionHandler?
    ) {
        didShowAlert = true
        showAlertCallCount += 1

        receivedTitle = title
        receivedMessage = message
        receivedCancelTitle = cancelTitle
        receivedOkTitle = okTitle

        self.cancelHandler = cancelHandler
        self.okHandler = okHandler
    }
}
