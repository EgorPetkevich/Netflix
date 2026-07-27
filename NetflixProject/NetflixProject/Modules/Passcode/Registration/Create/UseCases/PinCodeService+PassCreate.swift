//
//  PinCodeService+PassCreate.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 7.05.26.
//

import Foundation

struct PassCreatePinCodeServiceUseCase: PassCreatePinCodeServiceUseCaseProtocol {

    var pinLength: Int

    var unconfirmedPin: String? {
        get {
            service.unconfirmedPin
        } set {
            service.unconfirmedPin = newValue
        }
    }

    private let service: PinCodeService

    init(service: PinCodeService) {
        self.service = service
        self.pinLength = service.pinLength
    }

}
