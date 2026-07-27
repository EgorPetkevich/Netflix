//
//  MovieDetailsCoordinatorSpy.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 22.06.26.
//

import XCTest
@testable import NetflixProject

final class MovieDetailsCoordinatorSpy: MovieDetailsCoordinatorProtocol {

    var onPaywallDismiss: (() -> Void)?

    private(set) var didShowPaywall = false
    private(set) var showPaywallCallCount = 0

    private(set) var didFinish = false
    private(set) var finishCallCount = 0

    func showPaywall() {
        didShowPaywall = true
        showPaywallCallCount += 1
    }

    func finish() {
        didFinish = true
        finishCallCount += 1
    }
}
