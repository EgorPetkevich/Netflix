//
//  MediaCatalogAssembler.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 15.04.26.
//

import UIKit

final class MediaCatalogAssembler {

    private init() {}

    static func make(
        container: Container,
        section: MediaListSection,
        coordinator: MediaCatalogCoordinatorProtocol
    ) -> UIViewController {

        let adapter = MediaCatalogAdapter()
        let movieService = MediaCatalogMovieServiceUseCase(service: container.resolve())
        let tvService = MediaCatalogTVServiceUseCase(service: container.resolve())
        let alertService = MediaCatalogAlertServiceUseCase(service: container.resolve())

        let vm = MediaCatalogVM(
            section: section,
            coordinator: coordinator,
            movieService: movieService,
            tvService: tvService,
            alertService: alertService
        )

        let vc = MediaCatalogVC(
            navTitle: section.title,
            adapter: adapter,
            viewModel: vm
        )

        return vc
    }

}
