//
//  SKStoreReviewController+Review.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 12.05.26.
//

import StoreKit

extension SKStoreReviewController {

    public static func requestReview() {
        if let scene =
            UIApplication.shared
            .connectedScenes
            .first(
                where: { $0.activationState == .foregroundActive
                }) as? UIWindowScene {
            DispatchQueue.main.async {
                requestReview(in: scene)
            }
        }
    }

}
