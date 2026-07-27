//
//  Coordinator+Equatable.swift
//  NetflixProject
//
//  Created by George Popkich on 26.03.26.
//

import Foundation

extension Coordinator: Equatable {

    static func == (lhs: Coordinator, rhs: Coordinator) -> Bool {
        return lhs === rhs
    }

}
