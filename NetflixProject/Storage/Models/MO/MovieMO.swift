//
//  MovieMO.swift
//  Storage
//
//  Created by Egor Petkevich on 28.04.26.
//

import Foundation
import SwiftData

@Model
public class MovieMO: MediaMODescription {

    @Attribute(.unique) public var id: String

    public var date: Date
    public var isFavorite: Bool
    public var isBookmarked: Bool
    public var isSubscribed: Bool

    public var title: String
    public var originalTitle: String
    public var overview: String
    public var posterPath: String?
    public var backdropPath: String?
    public var releaseDate: String?
    public var adult: Bool
    public var popularity: Double
    public var voteAverage: Double
    public var voteCount: Int

    init(
        id: String,
        date: Date,
        isFavorite: Bool,
        isBookmarked: Bool,
        isSubscribed: Bool,
        title: String,
        originalTitle: String,
        overview: String,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        releaseDate: String? = nil,
        adult: Bool,
        popularity: Double,
        voteAverage: Double,
        voteCount: Int
    ) {
        self.id = id
        self.date = date
        self.isFavorite = isFavorite
        self.isBookmarked = isBookmarked
        self.isSubscribed = isSubscribed
        self.title = title
        self.originalTitle = originalTitle
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.adult = adult
        self.popularity = popularity
        self.voteAverage = voteAverage
        self.voteCount = voteCount
    }

    init(dto: MovieDTO) {
        self.id = dto.id
        self.date = dto.date
        self.isFavorite = dto.isFavorite
        self.isBookmarked = dto.isBookmarked
        self.isSubscribed = dto.isSubscribed
        self.title = dto.title
        self.originalTitle = dto.originalTitle
        self.overview = dto.overview
        self.posterPath = dto.posterPath
        self.backdropPath = dto.backdropPath
        self.releaseDate = dto.releaseDate
        self.adult = dto.adult
        self.popularity = dto.popularity
        self.voteAverage = dto.voteAverage
        self.voteCount = dto.voteCount
    }

    public func apply(dto: any MediaDTODescription) {
        guard let movieDTO = dto as? MovieDTO else {
            print("[MODTO]", "\(Self.self) apply failed: dto is type of \(Swift.type(of: dto))")
            return
        }
        self.id = movieDTO.id
        self.date = movieDTO.date
        self.isFavorite = movieDTO.isFavorite
        self.isBookmarked = movieDTO.isBookmarked
        self.title = movieDTO.title
        self.originalTitle = movieDTO.originalTitle
        self.overview = movieDTO.overview
        self.posterPath = movieDTO.posterPath
        self.backdropPath = movieDTO.backdropPath
        self.releaseDate = movieDTO.releaseDate
        self.adult = movieDTO.adult
        self.popularity = movieDTO.popularity
        self.voteAverage = movieDTO.voteAverage
        self.voteCount = movieDTO.voteCount
    }

    public func toDTO() -> (any MediaDTODescription)? {
        MovieDTO(mo: self)
    }

}
