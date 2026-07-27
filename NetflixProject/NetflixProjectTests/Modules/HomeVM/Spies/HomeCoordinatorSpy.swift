//
//  HomeCoordinatorSpy.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 18.06.26.
//

import Foundation
@testable import NetflixProject
@testable import Storage

final class HomeCoordinatorSpy: HomeCoordinatorProtocol {

    private(set) var didShowCatalog: Bool = false
    private(set) var didShowTvDetails: Bool = false
    private(set) var didShowMovieDetails: Bool = false
    private(set) var didShowDetails = false

    private(set) var receivedSection: MediaListSection?
    private(set) var receivedTvDTO: TvDTO?
    private(set) var receivedMovieDTO: MovieDTO?

    func showCatalog(with section: MediaListSection) {
        didShowCatalog = true
        receivedSection = section
    }

    func showTvDetails(for model: TvDTO) {
        didShowDetails = true
        didShowTvDetails = true
        receivedTvDTO = model
    }

    func showMovieDetails(for model: MovieDTO) {
        didShowDetails = true
        didShowMovieDetails = true
        receivedMovieDTO = model
    }
}
