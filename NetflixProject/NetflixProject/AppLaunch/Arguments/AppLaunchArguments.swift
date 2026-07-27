//
//  AppLaunchArguments.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 1.07.26.
//

import Foundation

enum AppLaunchArguments {
    static let uiTesting = "--ui-testing"
    static let screenMovieDetails = "--screen-movie-details"
    static let screenTvDetails = "--screen-tv-details"

    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains(uiTesting)
    }

    static var shouldOpenMovieDetails: Bool {
        ProcessInfo.processInfo.arguments.contains(screenMovieDetails)
    }

    static var shouldOpenTvDetails: Bool {
        ProcessInfo.processInfo.arguments.contains(screenTvDetails)
    }
}
