//
//  TVResponseModel.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 21.04.26.
//

import Foundation

struct TVResponseModel: Decodable {
    let page: Int
    let results: [TV]
    let totalPages: Int?
    let totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct TV: Decodable, Equatable, Hashable {
    let id: Int
    let name: String
    let originalName: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let firstAirDate: String?
    let genreIds: [Int]?
    let originCountry: [String]?
    let originalLanguage: String
    let popularity: Double
    let voteAverage: Double
    let voteCount: Int

    enum CodingKeys: String, CodingKey {
        case id, name, overview, popularity
        case originalName = "original_name"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case firstAirDate = "first_air_date"
        case genreIds = "genre_ids"
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
