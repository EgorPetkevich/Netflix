//
//  DetailsVM.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 16.04.26.
//

import Foundation
import Storage
import Combine

protocol TvDetailsCoordinatorProtocol: AnyObject {
    var onPaywallDismiss: (() -> Void)? { get set }

    func showPaywall()
    func finish()
}

protocol TvDetailsAllMediaStorageUseCaseProtocol {
    func fetch(by id: String) async -> (any MediaDTODescription)?
}

protocol TvDetaisMediaDataWorkerUseCaseProtocol {
    func updateOrDelete(dto: any MediaDTODescription) async throws
}

protocol TvDetailsPurchesServUseCaseProtocol {
    func hasActiveSubscription() async -> Bool
}

final class TvDetailsVM: TvDetailsViewModelProtocol {

    private enum PremiumAction {
        case like
        case bookmark
    }

    private var pendingPremiumAction: PremiumAction?

    // Out
    @CurrentValue(value: nil)
    var mediaModel: AnyPublisher<(any MediaDTODescription)?, Never>

    @CurrentValue(value: false)
    var isLiked: AnyPublisher<Bool, Never>

    @CurrentValue(value: false)
    var isBookmarked: AnyPublisher<Bool, Never>

    // In
    var backTapped: PassthroughSubject<Void, Never> = .init()

    var likeTapped: PassthroughSubject<Void, Never> = .init()

    var bookmarkTapped: PassthroughSubject<Void, Never> = .init()

    private var likeTask: Task<Void, Never>?

    private var bookMarkTask: Task<Void, Never>?

    private weak var coordinator: TvDetailsCoordinatorProtocol?

    private let storage: TvDetailsAllMediaStorageUseCaseProtocol
    private let dataWorker: TvDetaisMediaDataWorkerUseCaseProtocol
    private let purchaseService: TvDetailsPurchesServUseCaseProtocol

    private var bag: Set<AnyCancellable> = []

    init(
        model: any MediaDTODescription,
        coordinator: TvDetailsCoordinatorProtocol,
        storage: TvDetailsAllMediaStorageUseCaseProtocol,
        dataWorker: TvDetaisMediaDataWorkerUseCaseProtocol,
        purchaseService: TvDetailsPurchesServUseCaseProtocol
    ) {
        self.coordinator = coordinator
        self.storage = storage
        self.dataWorker = dataWorker
        self.purchaseService = purchaseService
        _mediaModel.combine.send(model)
        bind()
    }

    func onAppear() {
        Task { [weak self] in
            do {
                guard let self else { return }
                guard let shared = _mediaModel.combine.value else { return }
                let model = await storage.fetch(by: shared.id)
                if let model {
                    _mediaModel.combine.send(model)
                }
                _isLiked.combine.send(model?.isFavorite ?? false)
                _isBookmarked.combine.send(model?.isBookmarked ?? false)
            }

        }
    }

    private func bind() {
        backTapped.sink { [weak self] _ in
            self?.coordinator?.finish()
        }
        .store(in: &bag)

        likeTapped
            .sink { [weak self] _ in
                self?.performPremiumAction(.like)
            }
            .store(in: &bag)

        bookmarkTapped
            .sink { [weak self] _ in
                self?.performPremiumAction(.bookmark)
            }
            .store(in: &bag)

        coordinator?.onPaywallDismiss = { [weak self] in
            self?.continuePendingPremiumActionIfNeeded()
        }
    }

    private func toggleLike() {
        guard var model = _mediaModel.combine.value else { return }

        model.isFavorite.toggle()
        _mediaModel.combine.send(model)
        _isLiked.combine.value = model.isFavorite
        likeTask?.cancel()

        likeTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)

            if Task.isCancelled { return }

            try? await dataWorker.updateOrDelete(dto: model)

            _mediaModel.combine.send(model)
            _isLiked.combine.value = model.isFavorite
        }
    }

    private func toggleBookmark() {
        guard var model = _mediaModel.combine.value else { return }

        model.isBookmarked.toggle()
        _mediaModel.combine.send(model)
        _isBookmarked.combine.value = model.isBookmarked
        bookMarkTask?.cancel()

        bookMarkTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)

            if Task.isCancelled { return }

            try? await dataWorker.updateOrDelete(dto: model)

            _mediaModel.combine.send(model)
            _isBookmarked.combine.value = model.isBookmarked
        }
    }

    private func handlePremiumAction(_ action: PremiumAction) {
        switch action {
        case .like:
            toggleLike()
        case .bookmark:
            toggleBookmark()
        }
    }

    private func performPremiumAction(_ action: PremiumAction) {
        Task { [weak self] in
            guard let self else { return }

            let isPremium = await purchaseService.hasActiveSubscription()

            await MainActor.run {
                if isPremium {
                    self.handlePremiumAction(action)
                } else {
                    self.pendingPremiumAction = action
                    self.coordinator?.showPaywall()
                }
            }
        }
    }

    func continuePendingPremiumActionIfNeeded() {
        Task { [weak self] in
            guard let self else { return }

            let isPremium = await purchaseService.hasActiveSubscription()

            await MainActor.run {
                guard
                    isPremium,
                    let action = self.pendingPremiumAction
                else { return }

                self.pendingPremiumAction = nil
                self.handlePremiumAction(action)
            }
        }
    }

}
