//
//  LoginVC.swift
//  NetflixProject
//
//  Created by George Popkich on 30.03.26.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Lottie

protocol LoginViewModeOutProtocol {
    var keyBoardFrameObserver: Observable<CGRect> { get }
    var isPassSecureObserver: Observable<Bool> { get }
    var isPassValidObserver: Observable<Bool> { get }
    var isEmailValidObserver: Observable<Bool> { get }
    var isLoadingObserver: Observable<Bool> { get }
}

protocol LoginViewModeInProtocol {
    var isSecureDidTapSubject: PublishSubject<Void> { get }
    var loginDidTapSubject: PublishSubject<Void> { get }
    var googleLogDidTapSubject: PublishSubject<Void> { get }
    var guestModeDidTapSubject: PublishSubject<Void> { get }
    var signUpDidTapSubject: PublishSubject<Void> { get }
    var forgotPassDidTapSubject: PublishSubject<Void> { get }

    var emailTextSubject: BehaviorSubject<String> { get }
    var passwordTextSubject: BehaviorSubject<String> { get }
}

protocol LoginViewModelProtocol:
    LoginViewModeOutProtocol & LoginViewModeInProtocol { }

final class LoginVC: UIViewController {

    private enum Const {
        static let maxEmailTextFieldCharacters: Int = 100
        static let maxPasswordTextFieldCharacters: Int = 64

        static let loginButtonHeight: CGFloat = 64.0
        static let loginBottomDistanse: CGFloat = 180
        static let animationSize: CGFloat = 100
        static let googleLogButtonHeight: CGFloat = 50
        static let keyboardToContentSpacing: CGFloat = 34
    }

    private var bottomKeyBoardConstraint: Constraint?

    private lazy var logoImageView: UIImageView =
    UIImageView()
        .setImage(.authLogoNetflix)
        .setContentMode(.scaleAspectFit)

    private lazy var emailTextField: LineTextField =
    LineTextField()
        .setPlaceholder(L10n.authLoginEmailPlaceholder, color: .appGray3)
        .setKeyboardType(.emailAddress)

    private lazy var passwordTextField: LineTextField =
    LineTextField()
        .setPlaceholder(L10n.authLoginPasswordPlaceholder, color: .appGray3)
        .setKeyboardType(.default)
        .setSecure(true)

    private lazy var welcomeBackLabel: UILabel =
        .boldRoboto(
            L10n.authLoginWelcomeBack,
            size: 35.0,
            textColor: .appTextPrimary
        )
        .textAlignment(.center)

    private lazy var profilePicture: UIImageView =
    UIImageView()
        .setImage(.authHappyNetflixProfile)
        .setContentMode(.scaleAspectFit)

    private lazy var dontHaveAccLabel: UILabel =
        .mediumRoboto(
            L10n.authLoginDontHaveAccount,
            size: 16.0,
            textColor: .appDisable
        )
    private lazy var forgotPassButton: UIButton =
    UIButton(type: .system)
        .setTitle(L10n.authLoginForgotPassButton)
        .setTitleFont(font: FontFamily.Roboto.medium.font(size: 16.0))
        .setTitleColor(color: .appDisable)

    private lazy var loginButton: UIButton =
    ActionButton(type: .system)
        .applyStyle(.fill, color: .appActionRed)
        .setTitle(L10n.authLoginButton)

    private lazy var isSecureButton: UIButton =
    UIButton(type: .system)
        .setTitle(L10n.authLoginShowButton)
        .setTitleColor(color: .appGray3)
        .setTitleFont(font: FontFamily.Roboto.bold.font(size: 16.0))

    private lazy var googleLogButton: UIButton =
    UIButton()
        .setImage(.authGoogleButton)

    private lazy var signUpButton: UIButton =
    UIButton(type: .system)
        .setTitle(L10n.authLoginSignUpButton)
        .setTitleFont(font: FontFamily.Roboto.medium.font(size: 16.0))
        .setTitleColor(color: .appActionRed)

    private lazy var guestModeButton: UIButton =
    UIButton(type: .system)
        .setTitle(L10n.authLoginGuestButton)
        .setTitleFont(font: FontFamily.Roboto.bold.font(size: 16.0))
        .setTitleColor(color: .appDisable)

    private lazy var loadView: UIView =
    UIView()
        .setBgColor(.appWhite.withAlphaComponent(0.5))

    private lazy var loadAnimationView: LottieAnimationView =
    LottieAnimationView(name: "loadAnimation")

    private lazy var signUpContainer: UIView = UIView()

    private let viewModel: LoginViewModelProtocol

    private let bag = DisposeBag()

    init(viewModel: LoginViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        setupUI()
        setupConstraints()
        bind()
        bindButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profilePicture.setContentCompressionResistancePriority(
            .defaultLow,
            for: .vertical
        )
    }

    private func bind() {
        viewModel.keyBoardFrameObserver
            .map { $0.height }
            .map { height -> CGFloat in
                height > 0 ? Const.keyboardToContentSpacing + height : Const.loginBottomDistanse
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] inset in
                self?.bottomKeyBoardConstraint?.update(inset: inset)

                UIView.animate(withDuration: 0.25) {
                    self?.view.layoutIfNeeded()
                }
            })
            .disposed(by: bag)

        viewModel.keyBoardFrameObserver
            .map { $0.height > 0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] keyPresented in
                guard let self else { return }

                UIView.animate(withDuration: 0.25) {
                    self.profilePicture.alpha = keyPresented ? 0 : 1
                    self.welcomeBackLabel.alpha = keyPresented ? 0 : 1
                }
            })
            .disposed(by: bag)

        viewModel.isPassSecureObserver
            .distinctUntilChanged()
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isSecure in
                self?.passwordTextField.isSecure = isSecure
            })
            .disposed(by: bag)

        viewModel.isPassSecureObserver
            .distinctUntilChanged()
            .map { $0 ? L10n.authLoginShowButton : L10n.authLoginHideButton }
            .bind(to: isSecureButton.rx.title(for: .normal))
            .disposed(by: bag)

        viewModel.isEmailValidObserver
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isValid in
                let errorText = isValid ? "" : L10n.authLoginEmailInvalide
                self?.emailTextField.errorText = errorText
            })
            .disposed(by: bag)

        viewModel.isPassValidObserver
            .distinctUntilChanged()
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isValid in
                let errorText = isValid ? "" : L10n.authLoginPasswordInvalide
                self?.passwordTextField.errorText = errorText
                self?.profilePicture.image =
                isValid ? .authHappyNetflixProfile : .authSadNetflixProfile
            })
            .disposed(by: bag)

        viewModel.isLoadingObserver
            .distinctUntilChanged()
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] isLoading in
                guard let self else { return }
                loadView.isHidden = !isLoading
                isLoading ? loadAnimationView.play() : loadAnimationView.stop()
            })
            .disposed(by: bag)
    }

    private func bindButtons() {
        loginButton.rx.tap
            .do(onNext: { [weak self] in
                guard let self else { return }
                viewModel.emailTextSubject.onNext(emailTextField.text ?? "")
                viewModel.passwordTextSubject.onNext(passwordTextField.text ?? "")
            })
            .bind(to: viewModel.loginDidTapSubject)
            .disposed(by: bag)

        isSecureButton.rx.tap
            .bind(to: viewModel.isSecureDidTapSubject)
            .disposed(by: bag)

        googleLogButton.rx.tap
            .bind(to: viewModel.googleLogDidTapSubject)
            .disposed(by: bag)

        guestModeButton.rx.tap
            .bind(to: viewModel.guestModeDidTapSubject)
            .disposed(by: bag)

        signUpButton.rx.tap
            .bind(to: viewModel.signUpDidTapSubject)
            .disposed(by: bag)

        forgotPassButton.rx.tap
            .bind(to: viewModel.forgotPassDidTapSubject)
            .disposed(by: bag)
    }

    private func setupUI() {
        view.backgroundColor = .appBg
        view.addSubview(logoImageView)
        view.addSubview(profilePicture)
        view.addSubview(welcomeBackLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(forgotPassButton)
        view.addSubview(loginButton)
        view.addSubview(guestModeButton)
        view.addSubview(loadView)
        view.addSubview(googleLogButton)
        view.addSubview(signUpContainer)

        signUpContainer.addSubview(dontHaveAccLabel)
        signUpContainer.addSubview(signUpButton)

        loadView.addSubview(loadAnimationView)
        loadView.isHidden = true
        view.addGesture(self, action: #selector(dismissKeyboard))
        passwordTextField.addSubview(isSecureButton)

        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    private func setupConstraints() {
        loadView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        loadAnimationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(Const.animationSize)
        }
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(21.0)
        }
        profilePicture.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(30)
            make.bottom.equalTo(welcomeBackLabel.snp.top).offset(-20)
        }
        welcomeBackLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(emailTextField.snp.top).inset(-20)
            make.height.equalTo(30)
        }
        emailTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32.0)
            make.bottom.equalTo(passwordTextField.snp.top).inset(-16.0)
        }
        passwordTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32.0)
            make.bottom.equalTo(forgotPassButton.snp.top).inset(-6.0)
        }
        isSecureButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(18)
            make.right.equalToSuperview().inset(22.0)
        }
        forgotPassButton.snp.makeConstraints { make in
            make.trailing.equalTo(passwordTextField.snp.trailing)
            make.bottom.equalTo(loginButton.snp.top).inset(-8.0)
        }
        loginButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32.0)
            make.height.equalTo(Const.loginButtonHeight)
            bottomKeyBoardConstraint = make.bottom
                .equalToSuperview()
                .inset(Const.loginBottomDistanse)
                .constraint
        }
        signUpContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(loginButton.snp.bottom).offset(10)
            make.height.equalTo(15)
        }
        googleLogButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(guestModeButton.snp.top).inset(-10)
            make.height.equalTo(Const.googleLogButtonHeight)
            make.centerX.equalToSuperview()
        }
        guestModeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(7.0)
        }
        dontHaveAccLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        signUpButton.snp.makeConstraints { make in
            make.leading.equalTo(dontHaveAccLabel.snp.trailing).offset(8)
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}

extension LoginVC: LineTextFieldDelegate {

    func lineTextField(
        _ textField: LineTextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        let currentText = textField.text ?? ""

        guard let textRange = Range(range, in: currentText) else {
            return true
        }

        let updatedText = currentText.replacingCharacters(
            in: textRange,
            with: string
        )

        let maxLength: Int

        switch textField {
        case emailTextField:
            maxLength = Const.maxEmailTextFieldCharacters

        case passwordTextField:
            maxLength = Const.maxPasswordTextFieldCharacters

        default:
            return true
        }

        return updatedText.count <= maxLength
    }

}
