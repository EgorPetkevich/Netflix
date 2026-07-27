//
//  MediaCell.swift
//  NetflixProject
//
//  Created by George Popkich on 8.04.26.
//

import UIKit
import SnapKit
import Kingfisher
import Storage

final class MediaCell: UICollectionViewCell {

    private enum Const {
        static let rateRadius: CGFloat = 4.0
        static let imageRadius: CGFloat = 8.0
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .darkGray
        imageView.layer.cornerRadius = Const.imageRadius
        return imageView
    }()

    private lazy var rateView: RateView = RateView()

    override var isHighlighted: Bool {
        didSet {
            startTapAnimation()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        selectedBackgroundView?.frame = (
            selectedBackgroundView?.frame.insetBy(dx: 0, dy: 0))!
        selectedBackgroundView?.center.y = contentView.center.y
    }

    func setup(_ model: any MediaDTODescription) {
        rateView.rating = model.voteAverage
        setupPoster(with: model.posterPath)
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(rateView)
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        rateView.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(8.0)
        }
    }

    private func setupPoster(with posterUrl: String?) {
        guard
            let path = posterUrl,
            let url = URLBuilder.image(type: .poster(path: path), size: .w500)
        else { setFallbackImage(); return }

        imageView.kf.setImage(with: url)
    }

    private func setFallbackImage() {
        imageView.image = UIImage(systemName: "film")
    }

    private func startTapAnimation() {
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: .curveEaseInOut
        ) {
            self.contentView.alpha = self.isHighlighted ? 0.7 : 1.0

            self.transform = self.isHighlighted ?
            CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
        }
    }

}
