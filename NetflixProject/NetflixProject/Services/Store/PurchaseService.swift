//
//  PurchaseService.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 15.05.26.
//

import Foundation
import StoreKit

protocol PurchaseServiceProtocol {
    func fetchProducts() async throws -> [PurchaseProduct]
    func purchase(productId: String) async throws
    func restorePurchases() async throws
    func hasActiveSubscription() async -> Bool
}

final class PurchaseService: PurchaseServiceProtocol {

    enum ProductId {
        static let weekly = "com.netflix.weekly"
        static let monthly = "com.netflix.monthly"
        static let yearly = "com.netflix.yearly"
    }

    private let productIds: Set<String> = [
        ProductId.weekly,
        ProductId.monthly,
        ProductId.yearly
    ]

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            guard let self else { return }

            await listenForTransactions()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func fetchProducts() async throws -> [PurchaseProduct] {
        let products = try await Product.products(for: productIds)

        return products
            .sorted { $0.price < $1.price }
            .map(PurchaseProduct.init)
    }

    func purchase(productId: String) async throws {
        guard
            let product = try await Product.products(for: [productId]).first
        else {
            throw PurchaseServiceError.productNotFound(productId)
        }

        let result = try await product.purchase()

        switch result {

        case let .success(verificationResult):
            let transaction = try checkVerified(verificationResult)

            await transaction.finish()

        case .pending:
            throw PurchaseServiceError.purchasePending

        @unknown default:
            throw PurchaseServiceError.verificationFailed
        }
    }

    func restorePurchases() async throws {
        try await AppStore.sync()

        guard await hasActiveSubscription() else {
            throw PurchaseServiceError.subscriptionNotActive
        }
    }

    func hasActiveSubscription() async -> Bool {
        for await result in Transaction.currentEntitlements {

            guard let transaction = try? checkVerified(result) else {
                continue
            }

            guard productIds.contains(transaction.productID) else {
                continue
            }

            guard transaction.revocationDate == nil else {
                continue
            }

            if let expirationDate = transaction.expirationDate {
                return expirationDate > Date()
            }

            return true
        }

        return false
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            guard !Task.isCancelled else { return }

            do {
                let transaction = try checkVerified(result)

                await transaction.finish()
            } catch {
                continue
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case let .verified(value):
            return value
        case .unverified:
            throw PurchaseServiceError.verificationFailed
        }
    }
}
