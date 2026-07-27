//
//  RatingLevel.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 14.04.26.
//

import UIKit

enum RatingLevel {
    case low
    case medium
    case high

    init(rate: Double) {
        if rate == 0.0 {
            self = .high
            return
        }
        if rate < 5 {
            self = .low
        } else if rate < 7 {
            self = .medium
        } else {
            self = .high
        }
    }

    var color: UIColor {
        switch self {
        case .low: return .appRateRed
        case .medium: return .appRateYellow
        case .high: return .appRateGreen
        }
    }
}
