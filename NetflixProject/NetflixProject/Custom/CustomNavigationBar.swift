//
//  CustomNavigationBar.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 16.04.26.
//

import UIKit
import Combine
import SnapKit

final class CustomNavigationBar: UIView {

    private enum Const {
        static let height: CGFloat = 40.0
    }

    var backTapped: AnyPublisher<Void, Never> {
        backButton.tap()
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appGray3
        label.font = FontFamily.Roboto.bold.font(size: 18.0)
        label.textAlignment = .center
        return label
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(
            pointSize: 18,
            weight: .semibold
        )
        button.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: config),
            for: .normal
        )
        button.tintColor = .appActionRed
        return button
    }()

    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Const.height)
    }

    private func setupUI() {
        self.backgroundColor = .appBg
        self.addSubview(backButton)
        self.addSubview(titleLabel)
    }

    private func setupConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(Const.height)
        }
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().priority(.high)
            make.leading.greaterThanOrEqualTo(backButton.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }
    }

}
