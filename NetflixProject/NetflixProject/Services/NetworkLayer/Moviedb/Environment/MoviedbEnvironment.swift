//
//  MoviedbEnvironment.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 14.04.26.
//

import Foundation

enum MoviedbEnvironment: APIEnvironment {
    case tmdbAPI
    case tmdbImage

    var host: String {
        switch self {
        case .tmdbAPI: return "api.themoviedb.org"
        case .tmdbImage: return "image.tmdb.org"
        }
    }

    var scheme: String { return "https" }

    var defaultBasePath: String {
        switch self {
        case .tmdbAPI: return "/3"
        case .tmdbImage: return "/t/p"
        }
    }
}
