//
//  MovieDTO.swift
//  Storage
//
//  Created by Egor Petkevich on 28.04.26.
//

import Foundation

public struct MovieDTO: MediaDTODescription {

    public typealias MO = MovieMO

    public var id: String

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

    public init(
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

    init?(mo: MO) {
        self.id = mo.id
        self.date = mo.date
        self.isFavorite = mo.isFavorite
        self.isBookmarked = mo.isBookmarked
        self.isSubscribed = mo.isSubscribed
        self.title = mo.title
        self.originalTitle = mo.originalTitle
        self.overview = mo.overview
        self.posterPath = mo.posterPath
        self.backdropPath = mo.backdropPath
        self.releaseDate = mo.releaseDate
        self.adult = mo.adult
        self.popularity = mo.popularity
        self.voteAverage = mo.voteAverage
        self.voteCount = mo.voteCount
    }

    public func createMO() -> MovieMO {
        MovieMO(dto: self)
    }

}
