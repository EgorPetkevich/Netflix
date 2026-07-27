//
//  UIView+Shimmer.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 16.04.26.
//

import UIKit

extension UIView {

    func startShimmer() {
        stopShimmer()

        let light = UIColor.systemGray2.cgColor
        let dark = UIColor.systemGray4.cgColor

        let gradient = CAGradientLayer()
        gradient.colors = [dark, light, dark]

        gradient.frame = CGRect(
            x: -self.bounds.width,
            y: 0,
            width: self.bounds.width * 3,
            height: self.bounds.height
        )

        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.name = "shimmerLayer"

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1.2
        animation.repeatCount = .infinity

        gradient.add(animation, forKey: "shimmerAnimation")
        self.layer.addSublayer(gradient)

        self.layer.masksToBounds = true
    }

    func stopShimmer() {
        self.layer.sublayers?.removeAll { $0.name == "shimmerLayer" }
    }
}
