//
//  ActionButton.swift
//  NetflixProject
//
//  Created by George Popkich on 7.04.26.
//

import UIKit

final class ActionButton: UIButton {

    enum Style {
        case fill
        case border
    }

    var style: Style = .fill {
        didSet { updateAppearance() }
    }

    private var baseColor: UIColor = .appActionRed

    @discardableResult
    func applyStyle(_ style: Style, color: UIColor) -> Self {
        self.style = style
        self.baseColor = color

        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.setTitleFont(font: FontFamily.Roboto.bold.font(size: 16.0))

        updateAppearance()
        return self
    }

    private func updateAppearance() {
        switch style {
        case .fill:
            self.layer.borderWidth = 0
            self.setBg(color: baseColor)
            self.setTitleColor(.white, for: .normal)
        case .border:
            self.layer.borderWidth = 1.0
            self.layer.borderColor = baseColor.cgColor
            self.setBg(color: .clear)
            self.setTitleColor(baseColor, for: .normal)
            self.layer.borderColor = baseColor.cgColor
        }
    }

}
