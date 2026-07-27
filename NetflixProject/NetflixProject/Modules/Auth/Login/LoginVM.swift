//
//  LoginVM.swift
//  NetflixProject
//
//  Created by George Popkich on 30.03.26.
//

import Foundation
import RxSwift
import RxCocoa

protocol LoginCoordinatorProtocol: AnyObject {
    func presentGoogleAuth() async throws
    func openReset()
    func openRegister()
    func finish()
}

protocol LoginKeyboardHelperUseCaseProtocol {
    var frame: Observable<CGRect> { get }
}

protocol LoginInputValidatorUseCaseProtocol {
    func isValid(email: String) -> Bool
    func isValid(password: String) -> Bool
}

protocol LoginAuthServiceUseCaseProtocol {
    func signIn(email: String, password: String) -> Completable
    func signAsGuest() -> Completable
}

protocol LoginAlertServiceUseCaseProtocol {
    typealias AlertActionHandler = () -> Void

    func showAlert(
        title: String?,
        message: String?,
        cancelTitle: String?,
        cancelHandler: AlertActionHandler?,
        okTitle: String?
    )
}

final class LoginVM: LoginViewModelProtocol {

    // In
    var isSecureDidTapSubject: PublishSubject<Void> = .init()
    var loginDidTapSubject: PublishSubject<Void> = .init()
    var googleLogDidTapSubject: PublishSubject<Void> = .init()
    var guestModeDidTapSubject: PublishSubject<Void> = .init()
    var signUpDidTapSubject: PublishSubject<Void> = .init()
    var forgotPassDidTapSubject: PublishSubject<Void> = .init()
    var emailTextSubject: BehaviorSubject<String> = .init(value: "")
    var passwordTextSubject: BehaviorSubject<String> = .init(value: "")

    // Out
    @Subject()
    var keyBoardFrameObserver: Observable<CGRect>

    @Subject(value: true)
    var isPassSecureObserver: Observable<Bool>

    @Subject(value: true)
    var isPassValidObserver: Observable<Bool>

    @Subject()
    var isEmailValidObserver: Observable<Bool>

    @Subject()
    var isLoadingObserver: Observable<Bool>

    weak var coordinator: LoginCoordinatorProtocol?

    private let keyBoardHelper: LoginKeyboardHelperUseCaseProtocol
    private let inputValidator: LoginInputValidatorUseCaseProtocol
    private let authService: LoginAuthServiceUseCaseProtocol
    private let alertService: LoginAlertServiceUseCaseProtocol

    private let loger: Logger = Logger(LoginVM.self)

    private let bag = DisposeBag()

    init(
        coordinator: LoginCoordinatorProtocol,
        keyBoardHelper: LoginKeyboardHelperUseCaseProtocol,
        inputValidator: LoginInputValidatorUseCaseProtocol,
        authService: LoginAuthServiceUseCaseProtocol,
        alertService: LoginAlertServiceUseCaseProtocol
    ) {
        self.coordinator = coordinator
        self.keyBoardHelper = keyBoardHelper
        self.inputValidator = inputValidator
        self.authService = authService
        self.alertService = alertService
        bind()
        bindValidation()
    }

    private func bind() {
        keyBoardHelper.frame
            .observe(on: MainScheduler.instance)
            .bind(to: _keyBoardFrameObserver.rx)
            .disposed(by: bag)

        isSecureDidTapSubject
            .withLatestFrom(_isPassSecureObserver.rx)
            .map { !$0 }
            .bind(to: _isPassSecureObserver.rx)
            .disposed(by: bag)

        forgotPassDidTapSubject
            .subscribe(onNext: { [weak coordinator] in
                coordinator?.openReset()
            })
            .disposed(by: bag)

        googleLogDidTapSubject
            .subscribe(onNext: { [weak self] in
                Task { @MainActor in
                    do {
                        try await self?.coordinator?.presentGoogleAuth()
                        self?.loger.success("Google login succeeded")
                        UDManager.set(.authenticated, value: true)
                        self?.coordinator?.finish()
                    } catch {
                        self?.loger.error("Google login failed")
                        self?.showErrorAlert(with: error.localizedDescription)
                    }
                }
            })
            .disposed(by: bag)

        guestModeDidTapSubject
            .subscribe(onNext: { [weak self] in
                guard let self else { return }

                authService.signAsGuest()
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe(onCompleted: {
                        self.loger.success("Login as guest succeeded")
                        UDManager.set(.authenticated, value: true)
                        self.coordinator?.finish()
                    }, onError: { error in
                        self.loger.error("Login as guest failed")
                        self.showErrorAlert(with: error.localizedDescription)
                    })
                    .disposed(by: bag)
            })
            .disposed(by: bag)

        signUpDidTapSubject.subscribe(onNext: { [weak self] in
            self?.coordinator?.openRegister()
        })
        .disposed(by: bag)
    }

    private func bindValidation() {
        let isEmailValid = emailTextSubject
            .map { [weak self] in
                self?.inputValidator.isValid(email: $0) ?? false
            }
            .share(replay: 1)

        let isPasswordValid = passwordTextSubject
            .map { [weak self] in
                self?.inputValidator.isValid(password: $0) ?? false
            }
            .share(replay: 1)

        let credentials = loginDidTapSubject
            .withLatestFrom(Observable.combineLatest(
                isEmailValid,
                isPasswordValid
            ))
            .share()

        credentials
            .subscribe(onNext: { [weak self] emailValid, passValid in
                self?._isEmailValidObserver.rx.onNext(emailValid)
                self?._isPassValidObserver.rx.onNext(passValid)
            })
            .disposed(by: bag)

        credentials
            .filter { $0 && $1 }
            .subscribe(onNext: { [weak self] _, _ in
                guard
                    let self = self,
                    let email = try? emailTextSubject.value(),
                    let password = try? passwordTextSubject.value()
                else { return }

                _isLoadingObserver.rx.onNext(true)

                authService.signIn(email: email, password: password)
                    .observe(on: MainScheduler.instance)
                    .subscribe(
                        onCompleted: { [weak self] in
                            self?.loger.success("Login with password succeeded")
                            UDManager.set(.authenticated, value: true)
                            self?._isLoadingObserver.rx.onNext(false)
                            self?.coordinator?.finish()
                        },
                        onError: { [weak self] error in
                            self?.loger.error("Login with password failed")
                            self?._isLoadingObserver.rx.onNext(false)
                            self?.showErrorAlert(with: error.localizedDescription)
                        }
                    )
                    .disposed(by: bag)
            })
            .disposed(by: bag)
    }

    private func showErrorAlert(with message: String) {
        alertService.showAlert(
            title: L10n.authLoginErrorAlertTitle,
            message: message,
            cancelTitle: L10n.authLoginErrorAlertCancel,
            cancelHandler: { [weak self] in
                self?.loginDidTapSubject.onNext(())
            },
            okTitle: L10n.authLoginErrorAlertOk
        )
    }

}
