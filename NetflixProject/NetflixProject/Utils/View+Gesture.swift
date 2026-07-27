//
//  View+Gesture.swift
//  NetflixProject
//
//  Created by George Popkich on 30.03.26.
//

import UIKit

extension UIView {

    func addGesture(
        _ target: Any?,
        action selector: Selector
    ) {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: target,
            action: selector
        )
        self.addGestureRecognizer(tapGestureRecognizer)
    }

}
