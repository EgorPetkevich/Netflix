//
//  TVBackupModel.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 4.05.26.
//

import Foundation
import Storage

struct TVBackupModel: Codable {

    enum CodingKeys: CodingKey {
        case id
        case date
        case name
        case originalName
        case overview
        case posterPath
        case backdropPath
        case originCountry
        case firstAirDate
        case popularity
        case voteAverage
        case voteCount
        case isFavorite
        case isBookmarked
    }

    let dto: TvDTO

    init(dto: TvDTO) {
        self.dto = dto
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(String.self, forKey: .id)
        let date = try container.decode(Double.self, forKey: .date)

        let name = try container.decode(String.self, forKey: .name)
        let originalName = try container.decode(String.self, forKey: .originalName)

        let posterPath = try container.decode(String?.self, forKey: .posterPath)
        let backdropPath = try container.decode(String?.self, forKey: .backdropPath)

        let firstAirDate = try container.decode(String?.self, forKey: .firstAirDate)
        let originCountry = try container.decode([String]?.self, forKey: .originCountry)

        let popularity =  try container.decode(Double.self, forKey: .voteAverage)

        let voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        let voteCount = try container.decode(Int.self, forKey: .voteCount)

        let isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        let isBookmarked = try container.decode(Bool.self, forKey: .isBookmarked)

        self.dto = TvDTO(
            id: id,
            date: Date(timeIntervalSince1970: date),
            isFavorite: isFavorite,
            isBookmarked: isBookmarked,
            name: name,
            originalName: originalName,
            overview: "",
            posterPath: posterPath,
            backdropPath: backdropPath,
            firstAirDate: firstAirDate,
            originCountry: originCountry,
            popularity: popularity,
            voteAverage: voteAverage,
            voteCount: voteCount
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(dto.id, forKey: .id)
        try container.encode(dto.date.timeIntervalSince1970, forKey: .date)

        try container.encode(dto.name, forKey: .name)
        try container.encode(dto.originalName, forKey: .originalName)

        try container.encode(dto.overview, forKey: .overview)
        try container.encode(dto.posterPath, forKey: .posterPath)

        try container.encode(dto.backdropPath, forKey: .backdropPath)
        try container.encode(dto.firstAirDate, forKey: .firstAirDate)

        try container.encode(dto.originCountry, forKey: .originCountry)
        try container.encode(dto.popularity, forKey: .popularity)

        try container.encode(dto.voteAverage, forKey: .voteAverage)
        try container.encode(dto.voteCount, forKey: .voteCount)

        try container.encode(dto.isFavorite, forKey: .isFavorite)
        try container.encode(dto.isBookmarked, forKey: .isBookmarked)
    }

}
