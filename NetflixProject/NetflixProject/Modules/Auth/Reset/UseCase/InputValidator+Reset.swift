//
//  InputValidator+Reset.swift
//  NetflixProject
//
//  Created by George Popkich on 7.04.26.
//

import Foundation
import Combine

struct ResetInputValidatorUseCase: ResetInputValidatorUseCaseProtocol {

    private let validator: InputValidator

    init(validator: InputValidator) {
        self.validator = validator
    }

    func isValid(email: String) -> Bool {
        validator.isValid(email: email)
    }

}
