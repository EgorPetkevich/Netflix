//
//  RegisterVM.swift
//  NetflixProject
//
//  Created by George Popkich on 2.04.26.
//

import SwiftUI
import RxSwift
import Combine

protocol RegisterCoordinatorProtocol: AnyObject {
    func openLogin()
}

protocol RegisterAuthServiceUseCaseProtocol {
    func singUp(email: String, password: String) async throws
}

protocol RegisterInputValidatorUseCaseProtocol {
    func isValid(email: String) -> Bool
    func isValid(password: String) -> Bool
}

protocol RegisterAlertServiceUseCaseProtocol {
    typealias AlertActionHandler = () -> Void

    func showAlert(
        title: String?,
        message: String?,
        cancelTitle: String?,
        cancelHandler: AlertActionHandler?,
        okTitle: String?,
        okHandler: AlertActionHandler?
    )
}

final class RegisterVM: ObservableObject {

    @Published var emailText: String = ""
    @Published var emailErrorText: String?

    @Published var passwordText: String = ""
    @Published var passwordErrorText: String?

    @Published var repeatPassText: String = ""
    @Published var repeatPassErrorText: String?

    @Published var isKeyBoardShowing: Bool = false

    var coordinator: RegisterCoordinatorProtocol?

    private let inputValidator: RegisterInputValidatorUseCaseProtocol
    private let authService: RegisterAuthServiceUseCaseProtocol
    private let alertService: RegisterAlertServiceUseCaseProtocol

    private let logger: Logger = Logger(RegisterVM.self)

    private var bag = DisposeBag()

    init(
        coordinator: RegisterCoordinatorProtocol,
        inputValidator: RegisterInputValidatorUseCaseProtocol,
        authService: RegisterAuthServiceUseCaseProtocol,
        alertService: RegisterAlertServiceUseCaseProtocol
    ) {
        self.coordinator = coordinator
        self.inputValidator = inputValidator
        self.authService = authService
        self.alertService = alertService
    }

    func registerButtonDidTap() {
        let emailValid = isEmailValid()
        let passValid = isPassValid()

        guard emailValid && passValid else { return }
        Task { @MainActor in
            do {
                try await authService.singUp(email: emailText, password: passwordText)
                logger.success("User sing up succeeded")
                showSuccessSingUpAlert()
            } catch {
                logger.error("User sing up faild")
                showErrorAlert(with: error.localizedDescription)
            }
        }
    }

    func alreadyHaveAccButtonDidTap() {
        coordinator?.openLogin()
    }

    private func isPassValid() -> Bool {
        if passwordText == repeatPassText {
            if inputValidator.isValid(password: passwordText) {
                return true
            } else {
                passwordErrorText = L10n.authRegisterPasswordInvalide
                repeatPassErrorText = L10n.authRegisterPasswordInvalide
                return false
            }

        } else {
            repeatPassErrorText = L10n.authRegisterPassNotMath
            return false
        }
    }

    private func isEmailValid() -> Bool {
        if inputValidator.isValid(email: emailText) {
            return true
        } else {
            emailErrorText = L10n.authRegisterEmailInvalide
           return false
        }
    }

    private func showErrorAlert(with message: String) {
        alertService.showAlert(
            title: L10n.authRegisterErrorAlertTitle,
            message: message,
            cancelTitle: L10n.authRegisterErrorAlertCancel,
            cancelHandler: { [weak self] in
                self?.registerButtonDidTap()
            },
            okTitle: L10n.authLoginErrorAlertOk,
            okHandler: nil
        )
    }

    private func showSuccessSingUpAlert() {
        alertService.showAlert(
            title: L10n.authRegisterAlertSuccessTitle,
            message: L10n.authRegisterAlertSuccessTitle,
            cancelTitle: nil,
            cancelHandler: nil,
            okTitle: L10n.authLoginErrorAlertOk,
            okHandler: { [weak self] in
                self?.coordinator?.openLogin()
            }
        )
    }

}
