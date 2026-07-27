//
//  UINotification+Haptic.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 7.05.26.
//

import UIKit

extension UINotificationFeedbackGenerator {

    @MainActor
    static func triggerErrorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    @MainActor
    static func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    @MainActor
    static func triggerWarningHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
