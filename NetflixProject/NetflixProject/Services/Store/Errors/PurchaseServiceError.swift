//
//  PurchaseServiceError.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 18.05.26.
//

import Foundation

enum PurchaseServiceError: LocalizedError {
    case productNotFound(String)
    case purchasePending
    case verificationFailed
    case subscriptionNotActive

    var errorDescription: String? {
        switch self {
        case let .productNotFound(productId):
            return "Product not found: \(productId)"
        case .purchasePending:
            return "Purchase is pending"
        case .verificationFailed:
            return "Transaction verification failed"
        case .subscriptionNotActive:
            return "Subscription is not active"
        }
    }
}
