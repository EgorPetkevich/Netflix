//
//  Double+Rating.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 14.04.26.
//

import Foundation

extension Double {

    var formattedRating: String {
        let roundedRate = (self * 10).rounded() / 10
        if roundedRate == 0 { return "8.0" }
        return "\(roundedRate)"
    }

}
