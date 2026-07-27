//
//  KeychainUsage.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 16.06.26.
//

import Foundation

enum KeychainUsage {
    case passcode
    case barrierKey

    var service: String {
        switch self {
        case .passcode:
            return "com.yourapp.passcode"
        case .barrierKey:
            return "com.netflixProject.auth"
        }
    }

    var account: String {
        switch self {
        case .passcode:
            return "user_passcode"
        case .barrierKey:
            return "moviedb_bearer_token"
        }
    }
}
