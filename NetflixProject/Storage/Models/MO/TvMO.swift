//
//  TvMO.swift
//  Storage
//
//  Created by Egor Petkevich on 28.04.26.
//

import Foundation
import SwiftData

@Model
public class TvMO: MediaMODescription {
    @Attribute(.unique) public var id: String

    public var title: String {
        return self.name
    }

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

    init(
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

    init(dto: TvDTO) {
        self.id = dto.id
        self.date = dto.date
        self.isFavorite = dto.isFavorite
        self.isBookmarked = dto.isBookmarked
        self.name = dto.name
        self.originalName = dto.originalName
        self.overview = dto.overview
        self.posterPath = dto.posterPath
        self.backdropPath = dto.backdropPath
        self.firstAirDate = dto.firstAirDate
        self.originCountry = dto.originCountry
        self.popularity = dto.popularity
        self.voteAverage = dto.voteAverage
        self.voteCount = dto.voteCount
    }

    public func apply(dto: any MediaDTODescription) {
        guard let tvDTO = dto as? TvDTO else {
            print("[TODTO]", "\(Self.self) apply failed: dto is type of \(Swift.type(of: dto))")
            return
        }

        self.id = tvDTO.id
        self.date = tvDTO.date
        self.isFavorite = tvDTO.isFavorite
        self.isBookmarked = tvDTO.isBookmarked
        self.name = tvDTO.name
        self.originalName = tvDTO.originalName
        self.overview = tvDTO.overview
        self.posterPath = tvDTO.posterPath
        self.backdropPath = tvDTO.backdropPath
        self.firstAirDate = tvDTO.firstAirDate
        self.originCountry = tvDTO.originCountry
        self.popularity = tvDTO.popularity
        self.voteAverage = tvDTO.voteAverage
        self.voteCount = tvDTO.voteCount
    }

    public func toDTO() -> (any MediaDTODescription)? {
        TvDTO(mo: self)
    }

}
