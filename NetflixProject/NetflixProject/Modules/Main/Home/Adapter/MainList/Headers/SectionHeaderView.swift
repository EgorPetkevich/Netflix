//
//  SectionHeaderView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 14.04.26.
//

import UIKit
import Combine
import SnapKit

final class SectionHeaderView: UIView {

    @Passthrough
    var didTapShowAll: AnyPublisher<MediaSectionType, Never>

    private var type: MediaSectionType?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appGray3
        label.font = FontFamily.Roboto.bold.font(size: 18.0)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var showAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.mainHomeSectionButtonTitle, for: .normal)
        button.setTitleColor(.appActionRed, for: .normal)
        button.titleLabel?.font = FontFamily.Roboto.medium.font(size: 18.0)
        return button
    }()

    private var bag: Set<AnyCancellable> = []

    private var reuseBag: Set<AnyCancellable> = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with title: String, type: MediaSectionType) {
        self.titleLabel.text = title
        self.type = type
    }

    func bind(to subject: PassthroughSubject<MediaSectionType, Never>) {
        reuseBag = []

        didTapShowAll
            .subscribe(subject)
            .store(in: &reuseBag)
    }

    private func bind() {
        showAllButton.tap()
            .compactMap { [weak self] _ in
                self?.type
            }
            .subscribe(_didTapShowAll.combine)
            .store(in: &bag)
    }

    private func setupUI() {
        backgroundColor = .clear
        addSubview(titleLabel)
        addSubview(showAllButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().inset(8.0)
        }

        showAllButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(16)
        }
    }

}
