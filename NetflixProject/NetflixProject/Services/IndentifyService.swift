//
//  IndentifyService.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 6.05.26.
//

import Foundation
import LocalAuthentication

final class IdentifyService {

    func indentify() async throws {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        ) {

            let reason = "Auth yourself"

            try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )

        } else {
            if let error = error {
                throw error
            } else {
                throw NSError(
                    domain: "IdentifyServiceError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Biometry unavailable or not allowed"]
                )
            }
        }
    }
}
