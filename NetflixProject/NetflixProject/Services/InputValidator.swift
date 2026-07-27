//
//  InputValudator.swift
//  NetflixProject
//
//  Created by George Popkich on 31.03.26.
//

import Foundation

final class InputValidator {

    private enum Patterns {
        static let emailPattern: String =
        // swiftlint:disable:next line_length
        "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        static let passwordPattern: String =
        "^.*(?=.{6,})(?=.*[A-Z])(?=.*[a-zA-Z])(?=.*\\d)"
    }

    func isValid(email: String) -> Bool {
        validate(input: email, pattern: Patterns.emailPattern)
    }

    func isValid(password: String) -> Bool {
        validate(input: password, pattern: Patterns.passwordPattern)
    }

    private func validate(input: String, pattern: String) -> Bool {
        guard
            let regex = try? NSRegularExpression(
                pattern: pattern,
                options: .caseInsensitive
            )
        else { return false }

        let match = regex.firstMatch(
            in: input,
            options: [],
            range: NSRange(location: 0, length: input.count)
        )
        return match != nil
    }

}
