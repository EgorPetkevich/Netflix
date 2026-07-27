//
//  PersonMO.swift
//  Storage
//
//  Created by Egor Petkevich on 28.04.26.
//

import Foundation
import SwiftData

@Model
public class PersonMO: MediaMODescription {

    @Attribute(.unique) public var id: String

    public var title: String {
        return self.name
    }

    public var date: Date
    public var isFavorite: Bool
    public var isBookmarked: Bool

    public var name: String
    public var originalName: String
    public var posterPath: String?
    public var popularity: Double?
    public var gender: Int?
    public var knownForDepartment: String?

    public var voteAverage: Double {
        get {
            popularity ?? 0.0
        } set {
            popularity = newValue
        }

    }

    public var overview: String = ""

    @Relationship(deleteRule: .nullify)
    public var knownForMovies: [MovieMO] = []

    @Relationship(deleteRule: .nullify)
    public var knownForTvs: [TvMO] = []

    init(
        id: String,
        date: Date,
        isFavorite: Bool,
        isBookmarked: Bool,
        name: String,
        originalName: String,
        posterPath: String? = nil,
        popularity: Double? = nil,
        gender: Int? = nil,
        knownForDepartment: String? = nil,
        knownFor: [any MediaMODescription]
    ) {
        self.id = id
        self.date = date
        self.isFavorite = isFavorite
        self.isBookmarked = isBookmarked
        self.name = name
        self.originalName = originalName
        self.posterPath = posterPath
        self.popularity = popularity
        self.gender = gender
        self.knownForDepartment = knownForDepartment
        self.knownForMovies = knownFor.compactMap { $0 as? MovieMO }
        self.knownForTvs = knownFor.compactMap { $0 as? TvMO }
    }

    init(dto: PersonDTO) {
        self.id = dto.id
        self.date = dto.date
        self.isFavorite = dto.isFavorite
        self.isBookmarked = dto.isBookmarked
        self.name = dto.name
        self.originalName = dto.originalName
        self.posterPath = dto.posterPath
        self.popularity = dto.popularity
        self.gender = dto.gender
        self.knownForDepartment = dto.knownForDepartment
        self.knownForMovies = dto.knownFor.compactMap { $0.createMO() as? MovieMO }
        self.knownForTvs = dto.knownFor.compactMap { $0.createMO() as? TvMO }
    }

    public func apply(dto: any MediaDTODescription) {
        guard let personDTO = dto as? PersonDTO else {
            print("[PERSON]", "\(Self.self) apply failed: dto is type of \(Swift.type(of: dto))")
            return
        }

        self.id = personDTO.id
        self.date = personDTO.date
        self.isFavorite = personDTO.isFavorite
        self.isBookmarked = personDTO.isBookmarked
        self.name = personDTO.name
        self.originalName = personDTO.originalName
        self.posterPath = personDTO.posterPath
        self.popularity = personDTO.popularity
        self.gender = personDTO.gender
        self.knownForDepartment = personDTO.knownForDepartment
    }

    public func toDTO() -> (any MediaDTODescription)? {
        PersonDTO(mo: self)
    }

}
