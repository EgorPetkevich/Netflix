//
//  PersonBackupModel.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 4.05.26.
//

import Foundation
import Storage

struct PersonBackupModel: Codable {

    enum CodingKeys: CodingKey {
        case id
        case date
        case isFavorite
        case isBookmarked
        case name
        case originalName
        case posterPath
        case popularity
        case gender
        case knownForDepartment
        case knownFor
    }

    let dto: PersonDTO

    init(dto: PersonDTO) {
        self.dto = dto
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)

        let date = try container.decode(Double.self, forKey: .date)
        let name = try container.decode(String.self, forKey: .name)

        let posterPath = try container.decode(String?.self, forKey: .posterPath)
        let popularity = try container.decode(Double?.self, forKey: .popularity)

        let gender = try container.decode(Int?.self, forKey: .gender)
        let knownForDepartment = try container.decode(String?.self, forKey: .knownForDepartment)

        let isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        let isBookmarked = try container.decode(Bool.self, forKey: .isBookmarked)

        self.dto = PersonDTO(
            id: id,
            date: Date(timeIntervalSince1970: date),
            isFavorite: isFavorite,
            isBookmarked: isBookmarked,
            name: name,
            originalName: name,
            posterPath: posterPath,
            popularity: popularity,
            gender: gender,
            knownForDepartment: knownForDepartment,
            knownFor: []
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(dto.id, forKey: .id)
        try container.encode(dto.date.timeIntervalSince1970, forKey: .date)

        try container.encode(dto.isFavorite, forKey: .isFavorite)
        try container.encode(dto.isBookmarked, forKey: .isBookmarked)

        try container.encode(dto.name, forKey: .name)
        try container.encode(dto.originalName, forKey: .originalName)

        try container.encode(dto.posterPath, forKey: .posterPath)
        try container.encode(dto.popularity, forKey: .popularity)

        try container.encode(dto.gender, forKey: .gender)
        try container.encode(dto.knownForDepartment, forKey: .knownForDepartment)
    }

}
