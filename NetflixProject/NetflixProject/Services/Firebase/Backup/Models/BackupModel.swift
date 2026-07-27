//
//  BackupModel.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 4.05.26.
//

import Foundation
import Storage

enum BackupCollection: String, CaseIterable {
    case movies
    case tv
    case persons
}

struct BackupModel: Codable {

    enum CodingKeys: CodingKey {
        case type
    }

    let dto: any MediaDTODescription

    init(dto: any MediaDTODescription) {
        self.dto = dto
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        if type == BackupCollection.movies.rawValue {
            self.dto = try MovieBackupModel(from: decoder).dto
            return
        }

        if type == BackupCollection.tv.rawValue {
            self.dto = try TVBackupModel(from: decoder).dto
            return
        }

        if type == BackupCollection.persons.rawValue {
            self.dto = try PersonBackupModel(from: decoder).dto
            return
        }

        throw BackupError.unsupportedType
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let movieDTO = dto as? MovieDTO {
            try container.encode(BackupCollection.movies.rawValue, forKey: .type)
            try MovieBackupModel(dto: movieDTO).encode(to: encoder)

        } else if let tvDTO = dto as? TvDTO {
            try container.encode(BackupCollection.tv.rawValue, forKey: .type)
            try TVBackupModel(dto: tvDTO).encode(to: encoder)

        } else if let personDTO = dto as? PersonDTO {
            try container.encode(BackupCollection.persons.rawValue, forKey: .type)
            try PersonBackupModel(dto: personDTO).encode(to: encoder)
        }
    }

    func buidDict() -> [String: Any]? {
        guard
            let data = try? JSONEncoder().encode(self),
            let dict = try? JSONSerialization
                .jsonObject(with: data,
                            options: .fragmentsAllowed)
        else { return nil }

        return dict as? [String: Any]
    }

}
