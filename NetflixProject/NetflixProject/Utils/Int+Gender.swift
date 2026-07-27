//
//  Int+Gender.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 23.04.26.
//

import Foundation

extension Int {

    func genderText() -> String {
        switch self {
        case 1: return "Female"
        case 2: return "Male"
        default: return "Unknown"
        }
    }

}
