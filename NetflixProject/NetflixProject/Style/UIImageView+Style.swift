//
//  UIImageView+Style.swift
//  NetflixProject
//
//  Created by George Popkich on 27.03.26.
//

import UIKit

extension UIImageView {

    @discardableResult
    func setImage(_ image: UIImage) -> UIImageView {
        self.image = image
        return self
    }

    @discardableResult
    func setContentMode(_ contentMode: UIView.ContentMode) -> UIImageView {
        self.contentMode = contentMode
        return self
    }

    @discardableResult
    func setClipsToBounds(_ flag: Bool) -> UIImageView {
        self.clipsToBounds = flag
        return self
    }

}
