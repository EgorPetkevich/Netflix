//
//  HomeContentLoaderStub.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 18.06.26.
//

import Foundation
import Combine
@testable import NetflixProject
@testable import Storage

final class HomeContentLoaderStub: HomeContentLoaderProtocol {

    let stateSubject = PassthroughSubject<HomeLoadingState, Never>()

    var state: AnyPublisher<HomeLoadingState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var homeContentResult: Result<[MediaListSection], Error> = .success([])
    var nextPageResult: Result<[any MediaDTODescription], Error> = .success([])

    private(set) var loadHomeContentCallCount = 0
    private(set) var didLoadNextPage = false
    private(set) var receivedNextPageType: MediaSectionType?
    private(set) var receivedNextPage: Int?

    func loadHomeContent() -> AnyPublisher<[MediaListSection], Error> {
        loadHomeContentCallCount += 1
        return homeContentResult.publisher.eraseToAnyPublisher()
    }

    func loadNextPage(
        for type: MediaSectionType,
        page: Int
    ) -> AnyPublisher<[any MediaDTODescription], Error> {
        didLoadNextPage = true
        receivedNextPageType = type
        receivedNextPage = page

        return nextPageResult.publisher.eraseToAnyPublisher()
    }
}
