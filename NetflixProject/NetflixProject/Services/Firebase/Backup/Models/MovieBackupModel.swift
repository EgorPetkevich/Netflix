//
//  MovieBackupModel.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 4.05.26.
//

import Foundation
import Storage

struct MovieBackupModel: Codable {

    enum CodingKeys: CodingKey {
        case id
        case date
        case title
        case originalTitle
        case posterPath
        case backdropPath
        case releaseDate
        case overview
        case adult
        case voteAverage
        case voteCount
        case popularity
        case isFavorite
        case isBookmarked
        case isSubscribed
    }

    let dto: MovieDTO

    init(dto: MovieDTO) {
        self.dto = dto
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let date = try container.decode(Double.self, forKey: .date)
        let title = try container.decode(String.self, forKey: .title)
        let originalTitle = try container.decode(String.self, forKey: .originalTitle)
        let posterPath = try container.decode(String?.self, forKey: .posterPath)
        let backdropPath = try container.decode(String?.self, forKey: .backdropPath)
        let releaseDate = try container.decode(String?.self, forKey: .releaseDate)
        let overview = try container.decode(String.self, forKey: .overview)
        let adult = try container.decode(Bool.self, forKey: .adult)
        let voteCount = try container.decode(Int.self, forKey: .voteCount)
        let voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        let popularity = try container.decode(Double.self, forKey: .popularity)
        let isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        let isBookmarked = try container.decode(Bool.self, forKey: .isBookmarked)
        let isSubscribed = try container.decode(Bool.self, forKey: .isSubscribed)

        self.dto = MovieDTO(
            id: id,
            date: Date(timeIntervalSince1970: date),
            isFavorite: isFavorite,
            isBookmarked: isBookmarked,
            isSubscribed: isSubscribed,
            title: title,
            originalTitle: originalTitle,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            adult: adult,
            popularity: popularity,
            voteAverage: voteAverage,
            voteCount: voteCount
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(dto.id, forKey: .id)
        try container.encode(dto.date, forKey: .date)
        try container.encode(dto.title, forKey: .title)
        try container.encode(dto.originalTitle, forKey: .originalTitle)
        try container.encode(dto.posterPath, forKey: .posterPath)
        try container.encode(dto.backdropPath, forKey: .backdropPath)
        try container.encode(dto.releaseDate, forKey: .releaseDate)
        try container.encode(dto.overview, forKey: .overview)
        try container.encode(dto.adult, forKey: .adult)
        try container.encode(dto.voteCount, forKey: .voteCount)
        try container.encode(dto.voteAverage, forKey: .voteAverage)
        try container.encode(dto.popularity, forKey: .popularity)
        try container.encode(dto.isFavorite, forKey: .isFavorite)
        try container.encode(dto.isBookmarked, forKey: .isBookmarked)
        try container.encode(dto.isSubscribed, forKey: .isSubscribed)
    }

}
