//
//  UIButton+Style.swift
//  NetflixProject
//
//  Created by George Popkich on 27.03.26.
//

import UIKit

extension UIButton {

    @discardableResult
    func setTitle(
        _ title: String,
        state: UIControl.State = .normal
    ) -> UIButton {
        self.setTitle(title, for: state)
        return self
    }

    @discardableResult
    func setBg(color: UIColor) -> UIButton {
        self.backgroundColor = color
        return self
    }

    @discardableResult
    func setTitleFont(font: UIFont) -> UIButton {
        self.titleLabel?.font = font
        return self
    }

    @discardableResult
    func setImage(
        _ image: UIImage,
        state: UIControl.State = .normal
    ) -> UIButton {
        self.setImage(image, for: state)
        return self
    }

    func setTitleColor(
        color: UIColor,
        state: UIControl.State = .normal
    ) -> UIButton {
        self.setTitleColor(color, for: state)
        return self
    }

}

extension UIButton {

    static func iconButton(
        systemName: String,
        tintColor: UIColor = .appTextPrimary,
        size: CGFloat = 40
    ) -> UIButton {

        let button = UIButton(type: .system)

        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = tintColor
        config.image = UIImage(systemName: systemName)

        button.configuration = config
        button.frame.size = CGSize(width: size, height: size)

        return button
    }
}
