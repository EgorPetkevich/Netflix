//
//  PinCodeServiceImpl.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 7.05.26.
//

import Foundation

final class PinCodeService {

    private enum Const {
        static let pinLength = 4
    }

    let pinLength = Const.pinLength

    var unconfirmedPin: String?

    private let keychain: KeychainManaging

    init(keychain: KeychainManaging) {
        self.keychain = keychain
    }

    func save(pin: String) throws {
        keychain.save(pin, usage: .passcode)
    }

    func validateUnconfirmed(pin: String) -> Bool {
        guard let unconfirmedPin else { return false }
        return unconfirmedPin == pin
    }

    func deleteUnconfirmedPin() {
        return unconfirmedPin = nil
    }

    func validate(pin: String) -> Bool {
        guard
            let savedPin = keychain.get(.passcode)
        else {
            return false
        }

        return savedPin == pin
    }

    func removePin() {
        keychain.delete(.passcode)
    }

    func hasPin() -> Bool {
        guard
            let pin = keychain.get(.passcode)
        else {
            return false
        }

        return !pin.isEmpty
    }
}
