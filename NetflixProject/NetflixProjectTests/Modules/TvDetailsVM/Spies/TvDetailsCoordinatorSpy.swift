//
//  TvDetailsCoordinatorSpy.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 23.06.26.
//

import XCTest
@testable import NetflixProject

final class TvDetailsCoordinatorSpy: TvDetailsCoordinatorProtocol {

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
