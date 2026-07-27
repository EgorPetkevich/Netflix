//
//  MovieResponseModel.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 21.04.26.
//

import Foundation

struct MovieResponseModel: Decodable {
    let dates: MovieDates?
    let page: Int
    let results: [Movie]
    let totalPages: Int?
    let totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case dates, page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct MovieDates: Decodable {
    let maximum: String
    let minimum: String
}

struct Movie: Decodable, Equatable, Hashable {
    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let adult: Bool
    let genreIds: [Int]?
    let originalLanguage: String
    let popularity: Double
    let video: Bool
    let voteAverage: Double
    let voteCount: Int

    enum CodingKeys: String, CodingKey {
        case id, title, overview, adult, popularity, video
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
        case originalLanguage = "original_language"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
