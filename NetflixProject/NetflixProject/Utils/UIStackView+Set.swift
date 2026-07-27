//
//  UIStackView+setAxis.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 11.05.26.
//

import UIKit

extension UIStackView {

    @discardableResult
    func setAxis(_ axis: NSLayoutConstraint.Axis) -> UIStackView {
        self.axis = axis
        return self
    }

    @discardableResult
    func setSpacing(_ spacing: CGFloat) -> UIStackView {
        self.spacing = spacing
        return self
    }

    @discardableResult
    func setAlignment(_ alignment: Alignment) -> UIStackView {
        self.alignment = alignment
        return self
    }

}
