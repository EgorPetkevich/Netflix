//
//  DependecyValues+SearchService.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 21.04.26.
//

import Foundation
import ComposableArchitecture

enum SearchServiceKey: DependencyKey {
    static let liveValue: SearchServiceUseCaseProtocol = SearchService(
        mediaService: MediaService(
            session: NetworkSessionProvider(),
            fetchTokenService: FetchTokenService(
                keychainManager: KeychainManager()
            )
        )
    )
}

extension DependencyValues {

    var searchService: SearchServiceUseCaseProtocol {
        get { self[SearchServiceKey.self] }
        set { self[SearchServiceKey.self] = newValue }
    }
}
