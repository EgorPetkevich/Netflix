//
//  HomeLoaderError.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 18.05.26.
//

import Foundation

enum HomeLoaderError: LocalizedError {
    case emptyContent

    var errorDescription: String? {
        switch self {
        case .emptyContent:
            return "Home content is empty"
        }
    }
}
