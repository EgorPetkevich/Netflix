//
//  File.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 9.04.26.
//

import UIKit
import Combine
import Kingfisher
import SnapKit
import Storage

final class HeroHeaderView: UIView {

    private enum Const {
        static let rateRadius: CGFloat = 4.0
        static let imageRadius: CGFloat = 8.0
    }

    @Passthrough
    var headerDetailsTapped: AnyPublisher<Void, Never>

    private let containerView = UIView()
    private let gradientLayer = CAGradientLayer()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var rateView: RateView = RateView()

    private lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.8)
        label.font = FontFamily.Roboto.regular.font(size: 14.0)
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = FontFamily.Roboto.bold.font(size: 28.0)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private lazy var detailsButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()

        config.baseBackgroundColor = .appWhite
        config.baseForegroundColor = .appDark
        config.background.cornerRadius = 6
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 8, leading: 16, bottom: 8, trailing: 16
        )

        var attributedTitle = AttributedString(L10n.mainHomeDatailsButtonTitle)
        attributedTitle.font = FontFamily.Roboto.bold.font(size: 14.0)
        config.attributedTitle = attributedTitle
        button.configuration = config

        return button
    }()

    private lazy var bottomStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [detailsButton, rateView])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .fill
        return stack
    }()

    private var bag: Set<AnyCancellable> = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = containerView.bounds
    }

    func resizeHeader(to width: CGFloat) {
        let size = systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        )

        frame.size.height = size.height
    }

    func configure(with model: any MediaDTODescription) {
        titleLabel.text = model.title
        overviewLabel.text = model.overview
        rateView.rating = model.voteAverage
        setupPoster(with: model.posterPath)
    }

    func update(offset: CGFloat) {
        if offset < 0 {
            let diff = abs(offset)
            let scale = 1 + diff / bounds.height

            let scaledHeight = bounds.height * scale
            let deltaY = (scaledHeight - bounds.height) / 2

            containerView.transform =
            CGAffineTransform(translationX: 0, y: -deltaY)
                .scaledBy(x: scale, y: scale)
        }
    }

    private func bind() {
        detailsButton.tap()
            .subscribe(_headerDetailsTapped.combine)
            .store(in: &bag)
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.backgroundColor = .clear

        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.9).cgColor
        ]
        gradientLayer.locations = [0.4, 1.0]
        containerView.layer.addSublayer(gradientLayer)

        containerView.addSubview(titleLabel)
        containerView.addSubview(overviewLabel)
        containerView.addSubview(bottomStackView)
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16).priority(999)
            make.bottom.equalTo(overviewLabel.snp.top).offset(-8)
        }
        overviewLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24).priority(999)
            make.bottom.equalTo(bottomStackView.snp.top).offset(-16)
        }
        bottomStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func setupPoster(with posterUrl: String?) {
        guard
            let path = posterUrl,
            let url = URLBuilder.image(type: .poster(path: path), size: .original)
        else { setFallbackImage(); return }

        imageView.kf.setImage(with: url)
    }

    private func setFallbackImage() {
        imageView.image = UIImage(systemName: "film")
    }

}
