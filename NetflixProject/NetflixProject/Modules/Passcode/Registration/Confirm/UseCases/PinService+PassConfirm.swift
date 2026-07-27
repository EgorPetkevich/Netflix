//
//  PinService+PassConfirm.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 7.05.26.
//

import Foundation

struct PassConfirmPinCodeServiceUseCase: PassConfirmPinCodeServiceUseCaseProtocol {

    var pinLength: Int

    private let service: PinCodeService

    init(service: PinCodeService) {
        self.service = service
        self.pinLength = service.pinLength
    }

    func save(pin: String) throws {
        try service.save(pin: pin)
    }

    func validateUnconfirmed(pin: String) -> Bool {
        service.validateUnconfirmed(pin: pin)
    }

    func deleteUnconfirmedPin() {
        service.deleteUnconfirmedPin()
    }

}
