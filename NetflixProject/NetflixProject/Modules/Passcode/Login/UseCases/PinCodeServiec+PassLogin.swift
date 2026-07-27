//
//  PinCodeServiec+PassLogin.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 7.05.26.
//

import Foundation

struct PassLoginPinCodeServiceUseCase: PassLoginPinCodeServiceUseCaseProtocol {

    var pinLength: Int

    private let service: PinCodeService

    init(service: PinCodeService) {
        self.service = service
        self.pinLength = service.pinLength
    }

    func validate(pin: String) -> Bool {
        service.validate(pin: pin)
    }

}
