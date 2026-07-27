//
//  TvDTO.swift
//  Storage
//
//  Created by Egor Petkevich on 28.04.26.
//

import Foundation

public struct TvDTO: MediaDTODescription {

    public typealias MO = TvMO

    public var title: String {
        get {
            return self.name
        } set {
            self.name = newValue
        }
    }

    public var id: String

    public var date: Date
    public var isFavorite: Bool
    public var isBookmarked: Bool

    public var name: String
    public var originalName: String
    public var overview: String
    public var posterPath: String?
    public var backdropPath: String?
    public var firstAirDate: String?
    public var originCountry: [String]?
    public var popularity: Double
    public var voteAverage: Double
    public var voteCount: Int

    public init(
        id: String,
        date: Date,
        isFavorite: Bool,
        isBookmarked: Bool,
        name: String,
        originalName: String,
        overview: String,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        firstAirDate: String? = nil,
        originCountry: [String]? = nil,
        popularity: Double,
        voteAverage: Double,
        voteCount: Int
    ) {
        self.id = id
        self.date = date
        self.isFavorite = isFavorite
        self.isBookmarked = isBookmarked
        self.name = name
        self.originalName = originalName
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.firstAirDate = firstAirDate
        self.originCountry = originCountry
        self.popularity = popularity
        self.voteAverage = voteAverage
        self.voteCount = voteCount
    }

    public init(mo: TvMO) {
        self.id = mo.id
        self.date = mo.date
        self.isFavorite = mo.isFavorite
        self.isBookmarked = mo.isBookmarked
        self.name = mo.name
        self.originalName = mo.originalName
        self.overview = mo.overview
        self.posterPath = mo.posterPath
        self.backdropPath = mo.backdropPath
        self.firstAirDate = mo.firstAirDate
        self.originCountry = mo.originCountry
        self.popularity = mo.popularity
        self.voteAverage = mo.voteAverage
        self.voteCount = mo.voteCount
    }

    public func createMO() -> TvMO {
        TvMO(dto: self)
    }
}
