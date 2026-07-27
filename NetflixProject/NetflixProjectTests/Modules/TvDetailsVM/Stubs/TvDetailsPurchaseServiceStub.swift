//
//  TvDetailsPurchaseServiceStub.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 23.06.26.
//

import XCTest
@testable import NetflixProject

final class TvDetailsPurchaseServiceStub: TvDetailsPurchesServUseCaseProtocol {

    var hasActiveSubscriptionResult = false
    var hasActiveSubscriptionResults: [Bool] = []

    private(set) var hasActiveSubscriptionCallCount = 0

    func hasActiveSubscription() async -> Bool {
        hasActiveSubscriptionCallCount += 1

        if hasActiveSubscriptionResults.isEmpty == false {
            return hasActiveSubscriptionResults.removeFirst()
        }

        return hasActiveSubscriptionResult
    }
}
