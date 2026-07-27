//
//  SplashScreenVC.swift
//  NetflixProject
//
//  Created by George Popkich on 27.03.26.
//

import UIKit
import SnapKit

final class SplashScreenVC: UIViewController {

    private lazy var launchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .splashLogoNetflix
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        self.view.backgroundColor = .appBg
        self.view.addSubview(launchImageView)
    }

    private func setupConstraints() {
        launchImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

}
