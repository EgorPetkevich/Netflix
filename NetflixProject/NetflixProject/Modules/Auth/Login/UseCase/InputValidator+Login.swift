//
//  InputValidator+Login.swift
//  NetflixProject
//
//  Created by George Popkich on 31.03.26.
//

import Foundation

struct LoginInputValidatorUseCase: LoginInputValidatorUseCaseProtocol {

    private let validator: InputValidator

    init(validator: InputValidator) {
        self.validator = validator
    }

    func isValid(email: String) -> Bool {
        validator.isValid(email: email)
    }

    func isValid(password: String) -> Bool {
        validator.isValid(password: password)
    }

}
