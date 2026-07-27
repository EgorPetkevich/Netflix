//
//  MediaCatalogVM.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 15.04.26.
//

import Foundation
import Combine
import Storage

protocol MediaCatalogCoordinatorProtocol: AnyObject {
    func finish()
    func showTvDetails(for model: TvDTO)
    func showMovieDetails(for model: MovieDTO)
}

protocol MediaCatalogMovieServiceUseCaseProtocol {
    func getMovieList(
        type: MovieListType,
        page: Int
    ) -> AnyPublisher<[any MediaDTODescription], Error>
}

protocol MediaCatalogTVServiceUseCaseProtocol {
    func getTVList(
        type: TVListType,
        page: Int
    ) -> AnyPublisher<[any MediaDTODescription], Error>
}

protocol MediaCatalogAlertServiceUseCaseProtocol {
    typealias AlertActionHandler = () -> Void

    func showAlert(
        title: String?,
        message: String?,
        cancelHandler: AlertActionHandler?,
        okTitle: String?
    )
}

final class MediaCatalogVM: MediaCatalogViewModelProtocol {

    @CurrentValue(value: nil)
    private var section: AnyPublisher<MediaListSection?, Never>

    @CurrentValue(value: [])
    var items: AnyPublisher<[any MediaDTODescription], Never>

    // In
    var didSelectItem: PassthroughSubject<any MediaDTODescription, Never> = .init()

    var loadNextItems: PassthroughSubject<Void, Never> = .init()

    var backButtonTapped: PassthroughSubject<Void, Never> = .init()

    private weak var coordinator: MediaCatalogCoordinatorProtocol?

    private let movieService: MediaCatalogMovieServiceUseCaseProtocol

    private let tvService: MediaCatalogTVServiceUseCaseProtocol
    private let alertService: MediaCatalogAlertServiceUseCaseProtocol

    private let logger = Logger(MediaCatalogVM.self)

    private var bag: Set<AnyCancellable> = []
    private var isShowingErrorAlert = false

    init(
        section: MediaListSection,
        coordinator: MediaCatalogCoordinatorProtocol,
        movieService: MediaCatalogMovieServiceUseCaseProtocol,
        tvService: MediaCatalogTVServiceUseCaseProtocol,
        alertService: MediaCatalogAlertServiceUseCaseProtocol,
    ) {
        self.coordinator = coordinator
        self.movieService = movieService
        self.tvService = tvService
        self.alertService = alertService
        _section.combine.send(section)
        bind()
    }

    private func bind() {
        section
            .compactMap { $0?.media }
            .subscribe(_items.combine)
            .store(in: &bag)

        didSelectItem
            .sink { [weak self] model in
                self?.showDetails(for: model)
            }
            .store(in: &bag)

        loadNextItems
            .sink { [weak self] _ in
                self?.loadNextPage()
            }
            .store(in: &bag)

        backButtonTapped.sink { [weak self] _ in
            self?.coordinator?.finish()
        }
        .store(in: &bag)
    }

    func loadNextPage() {
        guard
            var currentSection = _section.combine.value,
            !currentSection.isLoading
        else { return }

        currentSection.isLoading = true
        let nextPage = currentSection.page + 1

        requestData(for: currentSection.type, page: nextPage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    let errorLocal = error.localizedDescription
                    logger.error(errorLocal)
                    showErrorAlert(with: errorLocal)
                }
                currentSection.isLoading = false
                _section.combine.send(currentSection)
            }, receiveValue: { newItems in
                currentSection.page = nextPage
                currentSection.media.append(contentsOf: newItems)
            })
            .store(in: &bag)

    }

    private func showDetails(for dto: any MediaDTODescription) {
        switch dto {
        case let dto as MovieDTO:
            coordinator?.showMovieDetails(for: dto)
        case let dto as TvDTO:
            coordinator?.showTvDetails(for: dto)
        default:
            return
        }
    }

    private func requestData(
        for type: MediaSectionType,
        page: Int
    ) -> AnyPublisher<[any MediaDTODescription], Error> {

        if let movieType = type.movieServiceType {
            return self.movieService.getMovieList(type: movieType, page: page)
        }

        if let tvType = type.tvServiceType {
            return self.tvService.getTVList(type: tvType, page: page)
        }

        return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
    }

    private func showErrorAlert(with message: String) {
        guard !isShowingErrorAlert else { return }
        isShowingErrorAlert = true

        alertService.showAlert(
            title: "Error",
            message: message,
            cancelHandler: { [weak self] in
                self?.isShowingErrorAlert = false
            },
            okTitle: L10n.authLoginErrorAlertOk
        )
    }

}
