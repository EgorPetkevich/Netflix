//
//  RxKeyboardHelper.swift
//  NetflixProject
//
//  Created by George Popkich on 30.03.26.
//

import UIKit
import RxSwift
import RxCocoa

public final class RxKeyboardHelper {

    public let frame: Observable<CGRect>

    public init() {
        let willShow = NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .compactMap { n -> CGRect? in
                (n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            }

        let willHide = NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .map { _ in CGRect.zero }

        self.frame = Observable.merge(willShow, willHide)
            .distinctUntilChanged()
    }
}
