//
//  UIButton+SetHeart.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 27.04.26.
//

import UIKit

extension UIButton {

    func setHeart(isLiked: Bool) {
        var config = self.configuration ?? .plain()

        config.image = UIImage(systemName: isLiked ? "heart.fill" : "heart")
        config.baseForegroundColor = isLiked ? .appActionRed : .appTextPrimary

        self.configuration = config
    }
}
