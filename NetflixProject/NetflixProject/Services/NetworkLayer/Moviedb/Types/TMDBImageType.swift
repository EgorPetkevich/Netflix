//
//  TMDBImageType.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 9.04.26.
//

import Foundation

enum TMDBImageSize: String {
    case w92, w154, w185, w342, w500, w780, original
}

enum TMDBImageType {
    case poster(path: String)
    case backdrop(path: String)
    case logo(path: String)

    var path: String {
        switch self {
        case .poster(let path), .backdrop(let path), .logo(let path):
            return path
        }
    }
}
