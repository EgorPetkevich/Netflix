//
//  ResetVC.swift
//  NetflixProject
//
//  Created by George Popkich on 7.04.26.
//

import UIKit
import Lottie
import SnapKit
import Combine

protocol ResetViewModelOutProtocol {
    var isEmailValid: AnyPublisher<String, Never> { get }
    var isLoading: AnyPublisher<Bool, Never> { get }
    var keyBoardFrame: AnyPublisher<CGRect, Never> { get }
}

protocol ResetViewModelInProtocol {
    var cancelDidTap: PassthroughSubject<Void, Never> { get }
    var resetDidTap: PassthroughSubject<String, Never> { get }
}

protocol ResetViewModelProtocol:
    ResetViewModelOutProtocol & ResetViewModelInProtocol { }

final class ResetVC: UIViewController {

    private enum Const {
        static let maxTextFieldCharacters: Int = 100

        static let resetButtonHeight: CGFloat = 64.0
        static let cancelButtonHeight: CGFloat = 64.0

        static let descriptContainerRadius: CGFloat = 8.0

        static let animationSize: CGFloat = 100
        static let cancelBottomDistanse: CGFloat = 8.0
        static let keyboardToContentSpacing: CGFloat = 0.0
    }

    private var bottomKeyBoardConstraint: Constraint?

    private lazy var logoImageView: UIImageView =
    UIImageView()
        .setImage(.authLogoNetflix)
        .setContentMode(.scaleAspectFit)

    private lazy var resetTitleLabel: UILabel =
        .boldRoboto(
            L10n.authResetTitle,
            size: 40.0,
            textColor: .appTextPrimary
        )
        .textAlignment(.center)

    private lazy var descriptionLabel: UILabel =
    UILabel
        .regularRoboto(
            L10n.authResetDescription,
            size: 20.0,
            textColor: .appTextPrimary
        )
        .numOfLines(0)
        .textAlignment(.left)

    private lazy var descriptionContainer: UIView =
    UIView()
        .setBgColor(.appTextFieldBg)

    private lazy var emailTextField: LineTextField =
    LineTextField()
        .setPlaceholder(L10n.authResetEmailPlaceholder, color: .appGray3)
        .setKeyboardType(.emailAddress)

    private lazy var resetButton: UIButton =
    ActionButton(type: .system)
        .applyStyle(.fill, color: .appActionRed)
        .setTitle(L10n.authResetButton)

    private lazy var cancelButton: UIButton =
    ActionButton(type: .system)
        .applyStyle(.border, color: .appActionRed)
        .setTitle(L10n.authResetCancelButton)

    private lazy var loadView: UIView =
    UIView()
        .setBgColor(.appWhite.withAlphaComponent(0.5))

    private lazy var loadAnimationView: LottieAnimationView =
    LottieAnimationView(name: "loadAnimation")

    private let viewModel: ResetViewModelProtocol

    private var bag: Set<AnyCancellable> = []

    init(viewModel: ResetViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstrains()
        bind()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        descriptionContainer.cornerRadius = Const.descriptContainerRadius
        descriptionContainer.setContentCompressionResistancePriority(
            .defaultLow, for: .vertical
        )
    }

    private func bind() {
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .map { !$0 }
            .assign(to: \.isHidden, on: loadAnimationView)
            .store(in: &bag)

        viewModel.isEmailValid
            .receive(on: DispatchQueue.main)
            .filter { !$0.isEmpty }
            .compactMap { $0 }
            .assign(to: \.errorText, on: emailTextField)
            .store(in: &bag)

        viewModel.keyBoardFrame
            .map { $0.height }
            .map { height in
                height > 0
                ? height + Const.keyboardToContentSpacing
                : Const.cancelBottomDistanse
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] inset in
                self?.bottomKeyBoardConstraint?.update(inset: inset)

                UIView.animate(withDuration: 0.25) {
                    self?.view.layoutIfNeeded()
                }
            }
            .store(in: &bag)

        viewModel.keyBoardFrame
            .map { $0.height > 0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] keyPresented in
                guard let self else { return }

                UIView.animate(withDuration: 0.25) {
                    self.descriptionContainer.alpha = keyPresented ? 0 : 1

                    if keyPresented {
                        self.resetTitleLabel.snp.remakeConstraints { make in
                            make.horizontalEdges.equalToSuperview().inset(32.0)
                            make.bottom.equalTo(self.emailTextField.snp.top).offset(-20)
                        }
                    } else {
                        self.resetTitleLabel.snp.remakeConstraints { make in
                            make.horizontalEdges.equalToSuperview().inset(32.0)
                            make.bottom.equalTo(self.descriptionContainer.snp.top).offset(-20)
                        }
                    }
                    self.view.layoutIfNeeded()
                }
            }
            .store(in: &bag)

        viewModel.isLoading
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                loadView.isHidden = !isLoading
                isLoading ? loadAnimationView.play() :
                loadAnimationView.stop()
            }
            .store(in: &bag)

        resetButton.tap()
            .compactMap { [weak emailTextField] in emailTextField?.text}
            .subscribe(viewModel.resetDidTap)
            .store(in: &bag)

        cancelButton.tap()
            .subscribe(viewModel.cancelDidTap)
            .store(in: &bag)
    }

    private func setupUI() {
        view.backgroundColor = .appBg
        view.addSubview(logoImageView)
        view.addSubview(resetTitleLabel)
        view.addSubview(emailTextField)
        view.addSubview(resetButton)
        view.addSubview(cancelButton)
        view.addSubview(loadView)
        view.addSubview(descriptionContainer)

        descriptionContainer.addSubview(descriptionLabel)

        loadView.addSubview(loadAnimationView)
        loadView.isHidden = true

        view.addGesture(self, action: #selector(dismissKeyboard))
        emailTextField.delegate = self
    }

    private func setupConstrains() {
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
        resetTitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32.0)
            make.bottom.equalTo(descriptionContainer.snp.top).offset(-20)
        }
        descriptionContainer.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32.0)
            make.bottom.equalTo(emailTextField.snp.top).inset(-40.0)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16.0)
        }
        emailTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32.0)
            make.bottom.equalTo(resetButton.snp.top).inset(-16.0)
        }
        resetButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32.0)
            make.height.equalTo(Const.resetButtonHeight)
            make.bottom.equalTo(cancelButton.snp.top).inset(-16.0)
        }
        cancelButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32.0)
            make.height.equalTo(Const.cancelButtonHeight)
            bottomKeyBoardConstraint = make.bottom
                .equalTo(view.safeAreaLayoutGuide.snp.bottom)
                .inset(Const.cancelBottomDistanse)
                .constraint
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}

extension ResetVC: LineTextFieldDelegate {

    func lineTextField(
        _ textField: LineTextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""

        if let textRange = Range(range, in: currentText) {
            let updatedText = currentText
                .replacingCharacters(in: textRange, with: string)

            if updatedText.count > Const.maxTextFieldCharacters {
                return false
            }
        }

        return true
    }

}
