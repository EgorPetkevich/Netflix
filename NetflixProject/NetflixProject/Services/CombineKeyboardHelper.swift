//
//  CombineKeyboardHelper.swift
//  NetflixProject
//
//  Created by George Popkich on 7.04.26.
//

import UIKit
import RxSwift
import RxCocoa
import Combine

final class CombineKeyboardHelper {

    let frame: AnyPublisher<CGRect, Never>

    init() {
        let willShowCombine = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGRect? in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            }

        let willHideCombine = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGRect.zero }

        self.frame = Publishers.Merge(willShowCombine, willHideCombine)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
