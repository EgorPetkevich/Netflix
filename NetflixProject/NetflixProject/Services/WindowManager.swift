//
//  WindowManager.swift
//  NetflixProject
//
//  Created by George Popkich on 26.03.26.
//

import UIKit

final class WindowManager {

    enum WindowType {
        case main
        case alert
    }

    private var windows: [WindowType: UIWindow] = [:]

    private let windowScene: UIWindowScene

    init(windowScene: UIWindowScene) {
        self.windowScene = windowScene
    }

    private func build(with type: WindowType) -> UIWindow {
        let window = UIWindow(windowScene: windowScene)
        windows[type] = window
        return window
    }

    func get(type: WindowType) -> UIWindow {
        return windows[type] ?? build(with: type)
    }

    func show(type: WindowType) {
        let window = get(type: type)
        window.makeKeyAndVisible()
    }

    func hideAndRemove(type: WindowType) {
        hide(type: type)
        windows[type] = nil
    }

    func hide(type: WindowType) {
        let window = get(type: type)
        window.resignKey()
    }

}
