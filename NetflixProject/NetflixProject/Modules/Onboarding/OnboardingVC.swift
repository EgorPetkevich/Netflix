//
//  OnboardingVC.swift
//  NetflixProject
//
//  Created by George Popkich on 27.03.26.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

protocol OnboardingViewModelProtocol {
    // In
    var signInButtonSubject: PublishSubject<Void> { get }
    var signUpButtonSubject: PublishSubject<Void> { get }
}

final class OnboardingVC: UIViewController {

    private enum Const {
        static let signInButtonHeight: CGFloat = 50.0
        static let currentPage: Int = 0
    }

    private lazy var firstPage: OnboardingPageView = OnboardingPageView(
        page: .init(
            title: L10n.onbFirstPageTitle,
            subtitle: L10n.onbFirstPageSubtitle,
            showsSignUp: false)
    )

    private lazy var secondPage: OnboardingPageView = OnboardingPageView(
        page: .init(
            title: L10n.onbSecondPageTitle,
            subtitle: L10n.onbSecondPageSubtitle,
            showsSignUp: true)
    )

    private lazy var bgImageView: UIImageView =
    UIImageView()
        .setImage(.onbBg)
        .setContentMode(.scaleToFill)

    private lazy var pageControlView = OnbPageControlView()

    private lazy var contentView: UIView =
    UIView()
        .setBgColor(.appDark.withAlphaComponent(0.56))

    private lazy var signInButton: UIButton =
    ActionButton(type: .system)
        .applyStyle(.fill, color: .appActionRed)
        .setTitle(L10n.onbFirstPageSignInButtonTitle)

    private lazy var swipeRight: UISwipeGestureRecognizer =
    UISwipeGestureRecognizer()
        .setDirection(.left)

    private var viewModel: OnboardingViewModelProtocol

    private var bag = DisposeBag()

    init(viewModel: OnboardingViewModelProtocol) {
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

    private func bind() {
        signInButton.rx.tap
            .bind(to: viewModel.signInButtonSubject)
            .disposed(by: bag)
        secondPage.signUpTap
            .bind(to: viewModel.signUpButtonSubject)
            .disposed(by: bag)
    }

    private func setupUI() {
        view.addSubview(bgImageView)
        bgImageView.addSubview(contentView)
        contentView.addSubview(pageControlView)
        contentView.addSubview(signInButton)
        bgImageView.isUserInteractionEnabled = true
        pageControlView.currentPage = Const.currentPage
        pageControlView.setPages([firstPage, secondPage])
    }

    private func setupConstrains() {
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(bgImageView.snp.centerY)
        }
        pageControlView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(contentView.snp.top).inset(-18.0)
            make.bottom.equalTo(signInButton.snp.top).inset(-20)
        }
        signInButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32.0)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(Const.signInButtonHeight)
        }

    }

}
