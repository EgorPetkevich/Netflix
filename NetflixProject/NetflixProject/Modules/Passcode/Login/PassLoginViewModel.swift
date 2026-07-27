//
//  PassLoginViewModel.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 6.05.26.
//

import SwiftUI
import UIKit
import Combine

protocol PassLoginCoordinatorProtocol: AnyObject {
    func onLoginSuccess()
}

protocol PassLoginIndentifyServiceUseCaseProtocol {
    func indentify() async throws
}

protocol PassLoginPinCodeServiceUseCaseProtocol {
    var pinLength: Int { get }
    func validate(pin: String) -> Bool
}

final class PassLoginViewModel: ObservableObject {

    @Published var pin: String = ""
    @Published var statusMessage: String = L10n.authPinFaceIdFailed
    @Published var authStatus: PassStatus = .failed

    let pinLength: Int

    private weak var coordinator: PassLoginCoordinatorProtocol?

    private let pinCodeService: PassLoginPinCodeServiceUseCaseProtocol
    private let identityService: PassLoginIndentifyServiceUseCaseProtocol

    init(
        coordinator: PassLoginCoordinatorProtocol,
        pinCodeService: PassLoginPinCodeServiceUseCaseProtocol,
        identityService: PassLoginIndentifyServiceUseCaseProtocol
    ) {
        self.coordinator = coordinator
        self.pinCodeService = pinCodeService
        self.identityService = identityService
        self.pinLength = pinCodeService.pinLength
    }

    func onAppear() {
        retryFaceID()
    }

    func retryFaceID() {
        statusMessage = L10n.authPinAuthenticating
        authStatus = .none

        Task {
            do {
                try await identityService.indentify()

                onSuccess(with: L10n.authPinSuccess)
                await fillPins()
                await onLoginWithAwait()
            } catch {
                onError(with: L10n.authPinFaceIdFailed)
            }
        }
    }

    func verifyPinIfNeeded() {
        guard
            pin.count == pinCodeService.pinLength,
            authStatus != .success
        else { return }

        if pinCodeService.validate(pin: pin) {
            onSuccess(with: L10n.authPinSuccess)

            Task {
                await onLoginWithAwait()
            }
        } else {
            onError(with: L10n.authPinIncorrectPasscode)
        }
    }

    private func onLoginWithAwait() async {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            coordinator?.onLoginSuccess()
        }
    }

    private func fillPins() async {
        Task { @MainActor in
            for _ in 0..<pinCodeService.pinLength {
                try? await Task.sleep(nanoseconds: 50_000_000)
                pin += " "
            }
        }
    }
    private func onSuccess(with statusMessage: String) {
        Task { @MainActor in
            self.statusMessage = statusMessage
            self.authStatus = .success
            UINotificationFeedbackGenerator.triggerSuccessHaptic()
        }
    }

    private func onError(with statusMessage: String) {
        Task { @MainActor in
            self.statusMessage = statusMessage
            authStatus = .failed
            pin = ""
            UINotificationFeedbackGenerator.triggerErrorHaptic()
        }
    }
}
