//
//  SearchService+Search.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 21.04.26.
//

import Foundation
import Storage

protocol SearchServiceUseCaseProtocol {
    func search(
        query: String,
        page: Int,
        type: SearchType
    ) async throws -> [any MediaDTODescription]
}

extension SearchService: SearchServiceUseCaseProtocol {}
