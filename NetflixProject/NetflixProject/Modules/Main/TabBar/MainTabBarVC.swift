//
//  MainTabBarVC.swift
//  NetflixProject
//
//  Created by George Popkich on 8.04.26.
//

import UIKit

final class MainTabBarVC: UITabBarController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        tabBar.tintColor = .appActionRed

        if #available(iOS 26.0, *) {
            tabBar.backgroundColor = .clear
        } else {
            tabBar.backgroundColor = .appBg
        }

    }

}
