//
//  PassRegViewModel.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 7.05.26.
//

import Foundation
import SwiftUI
import Combine

protocol PassCreateCoordinatorProtocol: AnyObject {
    func onCreateSuccess()
}

protocol PassCreatePinCodeServiceUseCaseProtocol {
    var pinLength: Int { get }
    var unconfirmedPin: String? { get set }
}

final class PassCreateViewModel: ObservableObject {

    @Published var pin: String = ""

    let pinLength: Int

    private weak var coordinator: PassCreateCoordinatorProtocol?

    private var pinCodeService: PassCreatePinCodeServiceUseCaseProtocol

    private var bag = Set<AnyCancellable>()

    init(
        coordinator: PassCreateCoordinatorProtocol,
        pinCodeService: PassCreatePinCodeServiceUseCaseProtocol
    ) {
        self.coordinator = coordinator
        self.pinCodeService = pinCodeService
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
                self?.handleContinue()
            }
            .store(in: &bag)
    }

    func handleContinue() {
        pinCodeService.unconfirmedPin = pin
        pin = ""
        coordinator?.onCreateSuccess()
    }

}
