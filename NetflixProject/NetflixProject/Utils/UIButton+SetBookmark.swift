//
//  UIButton+SetBookmark.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 27.04.26.
//

import UIKit

extension UIButton {

    func setBookmark(isSaved: Bool) {
        var config = self.configuration ?? .plain()

        config.image = UIImage(systemName: isSaved ? "bookmark.fill" : "bookmark")
        config.baseForegroundColor = isSaved ? .appRateYellow : .appTextPrimary

        self.configuration = config
    }
}
