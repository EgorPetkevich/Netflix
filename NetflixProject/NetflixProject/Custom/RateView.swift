//
//  RateView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 16.04.26.
//

import UIKit
import SnapKit

final class RateView: UIView {

    private enum Const {
        static let rateRadius: CGFloat = 8.0
    }

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = FontFamily.Roboto.medium.font(size: 14.0)
        label.textAlignment = .center
        return label
    }()

    private var rate: Double = 0.0

    var rating: Double {
        get { rate }

        set {
            rate = newValue
            ratingLabel.text = newValue.formattedRating
            self.backgroundColor = RatingLevel(rate: newValue).color
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.cornerRadius = Const.rateRadius
        self.addSubview(ratingLabel)
    }

    private func setupConstraints() {
        ratingLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
                .inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }
    }

}
