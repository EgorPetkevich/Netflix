//
//  PassConfirmViewModel.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 7.05.26.
//

import Foundation
import SwiftUI
import Combine

protocol PassConfirmCoordinator: AnyObject {
    func onConfirmSuccess()
    func popPassConfirm()
}

protocol PassConfirmPinCodeServiceUseCaseProtocol {
    var pinLength: Int { get }
    func save(pin: String) throws
    func deleteUnconfirmedPin()
    func validateUnconfirmed(pin: String) -> Bool
}

final class PassConfirmViewModel: ObservableObject {

    @Published var pin: String = ""
    @Published var message: String = "Re-enter your passcode"

    let pinLength: Int

    private weak var coordinator: PassConfirmCoordinator?

    private let pinCodeService: PassConfirmPinCodeServiceUseCaseProtocol

    private var bag = Set<AnyCancellable>()

    init(
        coordinator: PassConfirmCoordinator,
        pinCodeService: PassConfirmPinCodeServiceUseCaseProtocol
    ) {
        self.pinCodeService = pinCodeService
        self.coordinator = coordinator
        self.pinLength = pinCodeService.pinLength
        bind()
    }

    private func bind() {
        $pin
            .dropFirst()
            .filter { [weak self] newPin in
                guard let self = self else { return false }
                return newPin.count == self.pinLength
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleConfirm()
            }
            .store(in: &bag)
    }

    func backButtonTapped() {
        pinCodeService.deleteUnconfirmedPin()
        coordinator?.popPassConfirm()
    }

    func handleConfirm() {
        guard
            pinCodeService.validateUnconfirmed(pin: pin)
        else {
            onError(with: "Passcodes did not match")
            return
        }

        do {
            try pinCodeService.save(pin: pin)
            self.coordinator?.onConfirmSuccess()
        } catch {
            onError(with: "Failed to save passcode")
        }
    }

    private func onError(with message: String) {
        Task { @MainActor in
            UINotificationFeedbackGenerator.triggerErrorHaptic()
            self.message = message
            pin = ""
        }
    }
}
