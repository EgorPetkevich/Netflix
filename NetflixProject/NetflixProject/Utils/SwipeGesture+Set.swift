//
//  SwipeGesture+Set.swift
//  NetflixProject
//
//  Created by George Popkich on 30.03.26.
//

import UIKit

extension UISwipeGestureRecognizer {

    @discardableResult
    func setDirection(_ direction: Direction) -> UISwipeGestureRecognizer {
        self.direction = direction
        return self
    }

}
