//
//  ShowAllCell.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 14.04.26.
//

import UIKit
import SnapKit

final class ShowAllCell: UICollectionViewCell {

    private enum Const {
        static let circleSize: CGFloat = 60.0
    }

    private lazy var circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .appTextPrimary.withAlphaComponent(0.1)
        view.layer.cornerRadius = Const.circleSize / 2
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.appTextPrimary.withAlphaComponent(0.5).cgColor
        return view
    }()

    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        imageView.image = UIImage(
            systemName: "chevron.right", withConfiguration: config
        )
        imageView.tintColor = .appTextPrimary
        imageView.contentMode = .center
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.mainHomeCellShowButtonTitle
        label.textColor = .appTextPrimary
        label.font = FontFamily.Roboto.medium.font(size: 16)
        label.textAlignment = .center
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [circleView, titleLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()

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

    private func setupUI() {
        contentView.addSubview(stackView)
        circleView.addSubview(arrowImageView)
    }

    private func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        circleView.snp.makeConstraints { make in
            make.size.equalTo(Const.circleSize)
        }

        arrowImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
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
