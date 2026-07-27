//
//  HomeVM.swift
//  NetflixProject
//
//  Created by George Popkich on 8.04.26.
//

import Foundation
import Combine
import Storage

protocol HomeCoordinatorProtocol: AnyObject {
    func showCatalog(with section: MediaListSection)
    func showTvDetails(for model: TvDTO)
    func showMovieDetails(for model: MovieDTO)
}

protocol HomeAlertServiceUseCaseProtocol {
    typealias AlertActionHandler = () -> Void

    func showAlert(
        title: String,
        message: String,
        cancelTitle: String,
        cancelHandler: AlertActionHandler?,
        okTitle: String,
        okHandler: AlertActionHandler?
    )
}

final class HomeVM: HomeViewModelProtocol {

    private enum Const {
        static let pageLimit: Int = 2
    }

    @CurrentValue(value: [])
    var sections: AnyPublisher<[MediaListSection], Never>

    @CurrentValue(value: nil)
    var headerModel: AnyPublisher<(any MediaDTODescription)?, Never>

    // In
    var didSelectItem: PassthroughSubject<any MediaDTODescription, Never> = .init()

    var loadNextItems: PassthroughSubject<MediaSectionType, Never> = .init()

    var headerDetailsTapped: PassthroughSubject<any MediaDTODescription, Never> = .init()

    var showAllTapped: PassthroughSubject<MediaSectionType, Never> = .init()

    private let contentLoader: HomeContentLoaderProtocol
    private let alertService: HomeAlertServiceUseCaseProtocol

    private let logger = Logger(HomeVM.self)

    private weak var coordinator: HomeCoordinatorProtocol?

    private var bag: Set<AnyCancellable> = []
    private var isShowingErrorAlert = false

    init(
        coordinator: HomeCoordinatorProtocol,
        contentLoader: HomeContentLoaderProtocol,
        alertService: HomeAlertServiceUseCaseProtocol
    ) {
        self.coordinator = coordinator
        self.contentLoader = contentLoader
        self.alertService = alertService

        bind()
    }

    private func bind() {
        bindContentLoader()
        bindInputs()
    }

    private func bindContentLoader() {
        contentLoader.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleContentLoadingState(state)
            }
            .store(in: &bag)
        loadHomeContent()
    }

    private func loadHomeContent() {
        contentLoader.loadHomeContent()
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .sink { [weak self] sections in
                self?.handleLoadedSections(sections)
            }
            .store(in: &bag)
    }

    private func bindInputs() {
        loadNextItems
            .sink { [weak self] type in
                self?.loadNextPage(for: type)
            }
            .store(in: &bag)

        didSelectItem
            .sink { [weak self] model in
                self?.showDetails(for: model)
            }
            .store(in: &bag)

        headerDetailsTapped
            .sink { [weak self] model in
                self?.showDetails(for: model)
            }
            .store(in: &bag)

        showAllTapped
            .compactMap { [weak self] tappedType -> MediaListSection? in
                let currentSections = self?._sections.combine.value
                return currentSections?.first(where: { $0.type == tappedType })
            }
            .sink { [weak self] section in
                self?.coordinator?.showCatalog(with: section)
            }
            .store(in: &bag)
    }

    private func handleLoadedSections(_ sections: [MediaListSection]) {
        _sections.combine.send(sections)

        let header = sections
            .first(where: { $0.type == .tv(.airing) })?
            .media
            .first

        _headerModel.combine.send(header)
    }

    private func handleContentLoadingState(_ state: HomeLoadingState) {
        switch state {
        case .idle, .loading, .ready:
            break

        case .failed:
            showFetchErrorAlert()
        }
    }

    func loadNextPage(for type: MediaSectionType) {
        var currentSections = _sections.combine.value

        guard
            let index = currentSections.firstIndex(where: { $0.type == type }),
            currentSections[index].page < Const.pageLimit,
            !currentSections[index].isLoading
        else { return }

        currentSections[index].isLoading = true
        let nextPage = currentSections[index].page + 1

        contentLoader.loadNextPage(for: type, page: nextPage)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        let message = error.localizedDescription
                        self?.logger.error(message)
                        self?.showFetchErrorAlert()
                    }

                    currentSections[index].isLoading = false
                    self?._sections.combine.send(currentSections)
                },
                receiveValue: { newItems in
                    currentSections[index].page = nextPage
                    currentSections[index].media.append(contentsOf: newItems)
                }
            )
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

    private func showFetchErrorAlert() {
        guard !isShowingErrorAlert else { return }

        isShowingErrorAlert = true

        alertService.showAlert(
            title: L10n.mainHomeAlertConnectionTitleError,
            message: L10n.mainHomeAlertConnectionSubtitleError,
            cancelTitle: L10n.mainHomeAlertCancel,
            cancelHandler: { [weak self] in
                self?.isShowingErrorAlert = false
            },
            okTitle: L10n.mainHomeAlertTryAgain,
            okHandler: { [weak self] in
                self?.isShowingErrorAlert = false
                self?.loadHomeContent()
            }
        )
    }
}
