//
//  ChildType.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 5.05.26.
//

import Foundation
import Storage

extension FireBaseBackupService {

    enum ChildType: String {
        case movies
        case tv
        case persons

        static func get(_ dto: any MediaDTODescription) -> String? {
            switch dto {
            case is MovieDTO:
                return ChildType.movies.rawValue
            case is TvDTO:
                return ChildType.tv.rawValue
            case is PersonDTO:
                return ChildType.persons.rawValue
            default:
                return nil
            }
        }
    }

}
