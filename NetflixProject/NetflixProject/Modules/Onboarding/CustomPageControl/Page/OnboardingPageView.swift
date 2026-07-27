//
//  OnboardingPageView.swift
//  NetflixProject
//
//  Created by George Popkich on 30.03.26.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class OnboardingPageView: UIView {

    private enum Const {
        static let signUpButtonHeight: CGFloat = 35.0
        static let signUpButtonWidth: CGFloat = 200.0
    }

    private lazy var titleLabel: UILabel =
        .boldRoboto(
            "",
            size: 30.0,
            textColor: .appWhite
        )
        .textAlignment(.center)

    private lazy var subtitleLabel: UILabel =
        .regularRoboto(
            "",
            size: 20.0,
            textColor: .appWhite
        )
        .textAlignment(.center)
        .numOfLines(5)

    private lazy var signUpButton: UIButton =
    ActionButton(type: .system)
        .applyStyle(.fill, color: .appActionRed)
        .setTitle(L10n.onbSecondPageSignUpButtonTitle)

    var signUpTap: Observable<Void> {
        signUpButton.rx.tap.asObservable()
    }

    init(page: OnboardingPage) {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
        configure(page: page)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(signUpButton)
        signUpButton.clipsToBounds = true
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        subtitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(18.0)
        }
        signUpButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom).offset(40.0)
            make.height.equalTo(Const.signUpButtonHeight)
            make.width.equalTo(Const.signUpButtonWidth)
        }
    }

    func configure(page: OnboardingPage) {
        titleLabel.text = page.title
        subtitleLabel.text = page.subtitle
        signUpButton.isHidden = !page.showsSignUp
    }
}
