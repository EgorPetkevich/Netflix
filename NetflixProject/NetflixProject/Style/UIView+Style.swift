//
//  UIView+Style.swift
//  NetflixProject
//
//  Created by George Popkich on 27.03.26.
//

import UIKit

extension UIView {

    @discardableResult
    func setBgColor(_ color: UIColor) -> UIView {
        self.backgroundColor = color
        return self
    }

}
