//
//  UILabel+Style.swift
//  NetflixProject
//
//  Created by George Popkich on 27.03.26.
//

import UIKit

extension UILabel {

    static func boldRoboto(
        _ text: String,
        size: CGFloat,
        textColor: UIColor = .appTextPrimary
    ) -> UILabel {
        setTitle(
            text: text,
            font: FontFamily.Roboto.bold.font(size: size),
            textColor: textColor
        )
    }

    static func regularRoboto(
        _ text: String,
        size: CGFloat,
        textColor: UIColor = .appTextPrimary
    ) -> UILabel {
        setTitle(
            text: text,
            font: FontFamily.Roboto.regular.font(size: size),
            textColor: textColor
        )
    }

    static func mediumRoboto(
        _ text: String,
        size: CGFloat,
        textColor: UIColor = .appTextPrimary
    ) -> UILabel {
        setTitle(
            text: text,
            font: FontFamily.Roboto.medium.font(size: size),
            textColor: textColor
        )
    }

    static func setTitle(
        text: String,
        font: UIFont,
        textColor: UIColor = .appTextPrimary
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        return label
    }

    @discardableResult
    func numOfLines(_ num: Int) -> UILabel {
        self.numberOfLines = num
        return self
    }

    @discardableResult
    func textAlignment(_ alignment: NSTextAlignment) -> UILabel {
        self.textAlignment = alignment
        return self
    }

}

extension UILabel {

    @discardableResult
    func setText(_ text: String?) -> Self {
        self.text = text
        return self
    }

    @discardableResult
    func setTextColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }

    @discardableResult
    func setFont(_ font: UIFont) -> Self {
        self.font = font
        return self
    }

    @discardableResult
    func setAlignment(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }

    @discardableResult
    func setNumberOfLines(_ lines: Int) -> Self {
        self.numberOfLines = lines
        return self
    }

    @discardableResult
    func setLineBreakMode(_ mode: NSLineBreakMode) -> Self {
        self.lineBreakMode = mode
        return self
    }

}
