//
//  PurchaseProduct.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 18.05.26.
//

import Foundation
import StoreKit

struct PurchaseProduct: Equatable, Identifiable {

    let id: String
    let title: String
    let subtitle: String
    let productId: String
    let price: String
    let product: Product

    init(product: Product) {
        self.id = product.id
        self.productId = product.id
        self.title = product.displayName
        self.price = product.displayPrice
        self.product = product

        switch product.id {
        case PurchaseService.ProductId.weekly:
            self.subtitle = "Flexible access"

        case PurchaseService.ProductId.monthly:
            self.subtitle = "Most popular"

        case PurchaseService.ProductId.yearly:
            self.subtitle = "Best value"

        default:
            self.subtitle = product.description
        }
    }

    var introText: String? {
        guard let intro = product.subscription?.introductoryOffer else {
            return nil
        }

        let periodText = makePeriodText(from: intro.period)

        switch intro.paymentMode {
        case .freeTrial:
            return "\(periodText) free trial"

        case .payAsYouGo:
            return "\(intro.displayPrice) for \(periodText)"

        case .payUpFront:
            return "\(intro.displayPrice) upfront for \(periodText)"

        default:
            return nil
        }
    }

    var marketingPriceText: String {
        guard let introText else {
            return price
        }

        return "\(introText), then \(price)"
    }

    private func makePeriodText(
        from period: Product.SubscriptionPeriod
    ) -> String {

        let value = period.value

        let unit: String

        switch period.unit {

        case .day:
            unit = value == 1 ? "day" : "days"

        case .week:
            unit = value == 1 ? "week" : "weeks"

        case .month:
            unit = value == 1 ? "month" : "months"

        case .year:
            unit = value == 1 ? "year" : "years"

        @unknown default:
            unit = "days"
        }

        return "\(value)-\(unit)"
    }
}
