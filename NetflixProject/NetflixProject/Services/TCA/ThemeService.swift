//
//  ThemeService.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 23.04.26.
//

import UIKit
import ComposableArchitecture

enum AppTheme: String, CaseIterable, Equatable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct ThemeService {
    var getTheme: () -> AppTheme
    var setTheme: (AppTheme) -> Void
    var applyThemeIcon: @MainActor (AppTheme) -> Void
}

extension ThemeService: DependencyKey {

    static let liveValue: ThemeService = {
        let defaults = UserDefaults.standard
        let key = "app_theme_preference"

        return ThemeService(
            getTheme: {
                if let rawValue = defaults.string(forKey: key),
                   let theme = AppTheme(rawValue: rawValue) {
                    return theme
                }
                return .system
            },
            setTheme: { theme in
                defaults.set(theme.rawValue, forKey: key)

                DispatchQueue.main.async {
                    let scenes = UIApplication.shared.connectedScenes
                    let windowScene = scenes.first as? UIWindowScene

                    windowScene?.windows.forEach { window in
                        UIView.transition(
                            with: window,
                            duration: 0.3,
                            options: .transitionCrossDissolve,
                            animations: {
                                window.overrideUserInterfaceStyle = theme.userInterfaceStyle
                            },
                            completion: nil
                        )
                    }
                }
            },
            applyThemeIcon: { theme in

                let iconName: String?

                switch theme {
                case .system:
                    iconName = nil
                case .light:
                    iconName = "AppIcon-Light"
                case .dark:
                    iconName = "AppIcon-Dark"
                }

                guard UIApplication.shared.alternateIconName != iconName else { return }

                UIApplication.shared.setAlternateIconName(iconName) { error in
                    if let error {
                        print("[ThemeService]: \(error.localizedDescription)")
                    }
                }
            }
        )
    }()
}

extension DependencyValues {
    var themeService: ThemeService {
        get { self[ThemeService.self] }
        set { self[ThemeService.self] = newValue }
    }
}
