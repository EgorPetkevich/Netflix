//
//  ResetVM.swift
//  NetflixProject
//
//  Created by George Popkich on 7.04.26.
//

import Foundation
import Combine
internal import CoreGraphics

protocol ResetRouterProtocol {
    func finsh()
}

protocol ResetAuthServiceUseCaseProtocol {
    func resetPassword(email: String) -> AnyPublisher<Void, Error>
}

protocol ResetInputValidatorUseCaseProtocol {
    func isValid(email: String) -> Bool
}

protocol ResetKeyboardHalperUseCaseProtocol {
    var frame: AnyPublisher<CGRect, Never> { get }
}

protocol ResetAlertServiceUseCaseProtocol {
    typealias AlertActionHandler = () -> Void

    func showAlert(
        title: String?,
        message: String?,
        cancelTitle: String?,
        cancelHandler: AlertActionHandler?,
        okTitle: String?
    )
}

final class ResetViewModel: ResetViewModelProtocol {

    // In
    var cancelDidTap: PassthroughSubject<Void, Never> = .init()
    var resetDidTap: PassthroughSubject<String, Never> = .init()

    // Out
    @CurrentValue(value: false)
    var isLoading: AnyPublisher<Bool, Never>

    @CurrentValue(value: "")
    var isEmailValid: AnyPublisher<String, Never>

    @CurrentValue(value: .zero)
    var keyBoardFrame: AnyPublisher<CGRect, Never>

    private let router: ResetRouterProtocol
    private let keyBoardHelper: ResetKeyboardHalperUseCaseProtocol
    private let inputValidator: ResetInputValidatorUseCaseProtocol
    private let authService: ResetAuthServiceUseCaseProtocol
    private let alertSerive: ResetAlertServiceUseCaseProtocol

    private var bag: Set<AnyCancellable> = []

    init(
        router: ResetRouterProtocol,
        keyBoardHelper: ResetKeyboardHalperUseCaseProtocol,
        inputValidator: ResetInputValidatorUseCaseProtocol,
        authService: ResetAuthServiceUseCaseProtocol,
        alertService: ResetAlertServiceUseCaseProtocol
    ) {
        self.router = router
        self.keyBoardHelper = keyBoardHelper
        self.inputValidator = inputValidator
        self.authService = authService
        self.alertSerive = alertService
        bind()
    }

    private func bind() {
        cancelDidTap
            .sink(receiveValue: { [weak self] in
                self?.router.finsh()
            })
            .store(in: &bag)

        keyBoardHelper.frame
            .subscribe(_keyBoardFrame.combine)
            .store(in: &bag)

        resetDidTap
            .handleEvents(
                receiveCompletion: { [weak self] _ in
                    self?._isLoading.combine.send(false)
                },
                receiveCancel: { [weak self] in
                    self?._isLoading.combine.send(false)
                }
            )
            .flatMap { [weak self] email -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }

                guard inputValidator.isValid(email: email) else {
                    _isEmailValid.combine.send(L10n.authResetEmailInvalide)
                    return Empty().eraseToAnyPublisher()
                }

                _isLoading.combine.send(true)

                return authService.resetPassword(email: email)
                    .receive(on: DispatchQueue.main)
                    .handleEvents(receiveCompletion: { [weak self] _ in
                        self?._isLoading.combine.send(false)
                    })
                    .catch { [weak self] error -> Empty<Void, Never> in
                        self?.showErrorAlert(with: error.localizedDescription)
                        return Empty()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] in
                self?.showSuccessAlert()
            }
            .store(in: &bag)
    }

    private func showErrorAlert(with message: String) {
        alertSerive.showAlert(
            title: L10n.authResetErrorAlertTitle,
            message: message,
            cancelTitle: L10n.authResetErrorAlertCancel,
            cancelHandler: nil,
            okTitle: L10n.authResetErrorAlertOk
        )
    }

    private func showSuccessAlert() {
        alertSerive.showAlert(
            title: L10n.authResetSuccessAlertTitle,
            message: L10n.authResetSuccessAlertMessage,
            cancelTitle: nil,
            cancelHandler: nil,
            okTitle: L10n.authResetSuccessAlertOk
        )
    }

}
