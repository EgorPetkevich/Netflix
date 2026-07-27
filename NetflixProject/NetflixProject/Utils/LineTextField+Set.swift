//
//  LineTextField+Set.swift
//  NetflixProject
//
//  Created by George Popkich on 30.03.26.
//

import UIKit

extension LineTextField {

    @discardableResult
    func setPlaceholder(_ text: String) -> LineTextField {
        self.placeholder = text
        return self
    }

    @discardableResult
    func setErrorText(_ text: String) -> LineTextField {
        self.errorText = text
        return self
    }

    @discardableResult
    func setPlaceholder(_ text: String, color: UIColor) -> LineTextField {
        self.setupPlaceholder(text, color: color)
        return self
    }

    @discardableResult
    func setKeyboardType(_ type: UIKeyboardType) -> LineTextField {
        self.keyboardType = type
        return self
    }

    func setSecure(_ isSecure: Bool) -> LineTextField {
        self.isSecure = isSecure
        return self
    }

}
