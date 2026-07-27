//
//  Description.swift
//  Storage
//
//  Created by Egor Petkevich on 28.04.26.
//

import Foundation
import SwiftData

public protocol MediaMODescription: PersistentModel {
    var id: String { get set }
    var date: Date { get set }

    var title: String { get }
    var posterPath: String? { get set }
    var voteAverage: Double { get set }
    var overview: String { get set }

    var isFavorite: Bool { get set }
    var isBookmarked: Bool { get set }

    func apply(dto: any MediaDTODescription)

    func toDTO() -> (any MediaDTODescription)?
}

public protocol MediaDTODescription {

    associatedtype MO: MediaMODescription

    var id: String { get set }
    var date: Date { get set }

    var title: String { get set }
    var posterPath: String? { get set }
    var voteAverage: Double { get set }
    var overview: String { get set }

    var isFavorite: Bool { get set }
    var isBookmarked: Bool { get set }

    func createMO() -> MO
}
