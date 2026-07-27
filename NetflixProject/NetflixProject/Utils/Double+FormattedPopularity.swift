//
//  Double+FormattedPopularity.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 30.04.26.
//

import Foundation

extension Double {

    var formattedPopularity: String {

        let realValue = self * 10_000

        let absValue = abs(realValue)
        let sign = self < 0 ? "-" : ""

        switch absValue {
        case 1_000_000...:
            let millions = Int(absValue / 1_000_000)
            return "\(sign)\(millions)m"

        case 1_000..<1_000_000:
            let thousands = Int(absValue / 1_000)
            return "\(sign)\(thousands)k"

        default:
            let units = Int(absValue)
            return "\(sign)\(units)"
        }
    }
}
