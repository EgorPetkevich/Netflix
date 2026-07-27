//
//  PassStatus.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 6.05.26.
//

import SwiftUI

enum PassStatus {
    case none
    case success
    case failed

    var statusColor: Color {
        switch self {
        case .none:
            return .secondary
        case .success:
            return .green
        case .failed:
            return .red
        }
    }
}
