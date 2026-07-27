//
//  MovieDetailsVM.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 8.05.26.
//

import Foundation
import Storage
import Combine

protocol MovieDetailsCoordinatorProtocol: AnyObject {
    var onPaywallDismiss: (() -> Void)? { get set }

    func showPaywall()
    func finish()
}

protocol MovieDetailsStorageUseCaseProtocol {
    func fetch(by id: String) async -> MovieDTO?
}

protocol MovieDetaisMediaDataWorkerUseCaseProtocol {
    func updateOrDelete(dto: MovieDTO) async throws
}

protocol MovieDetailsPurchesServUseCaseProtocol {
    func hasActiveSubscription() async -> Bool
}

final class MovieDetailsVM: MovieDetailsViewModelProtocol {

    private enum PremiumAction {
        case like
        case bookmark
        case subscribe
    }

    private var pendingPremiumAction: PremiumAction?

    // Out
    @CurrentValue(value: nil)
    var mediaModel: AnyPublisher<MovieDTO?, Never>

    @CurrentValue(value: false)
    var isLiked: AnyPublisher<Bool, Never>

    @CurrentValue(value: false)
    var isBookmarked: AnyPublisher<Bool, Never>

    @CurrentValue(value: false)
    var isSubscribed: AnyPublisher<Bool, Never>

    @CurrentValue(value: false)
    var canShowSubscribeButton: AnyPublisher<Bool, Never>

    // In
    var backTapped: PassthroughSubject<Void, Never> = .init()
    var likeTapped: PassthroughSubject<Void, Never> = .init()
    var bookmarkTapped: PassthroughSubject<Void, Never> = .init()
    var subscribeTapped: PassthroughSubject<Void, Never> = .init()

    private var updateTask: Task<Void, Never>?

    private weak var coordinator: MovieDetailsCoordinatorProtocol?

    private let storage: MovieDetailsStorageUseCaseProtocol
    private let dataWorker: MovieDetaisMediaDataWorkerUseCaseProtocol
    private let purchaseService: MovieDetailsPurchesServUseCaseProtocol

    private var bag: Set<AnyCancellable> = []

    init(
        model: MovieDTO,
        coordinator: MovieDetailsCoordinatorProtocol,
        storage: MovieDetailsStorageUseCaseProtocol,
        dataWorker: MovieDetaisMediaDataWorkerUseCaseProtocol,
        purchaseService: MovieDetailsPurchesServUseCaseProtocol
    ) {
        self.coordinator = coordinator
        self.storage = storage
        self.dataWorker = dataWorker
        self.purchaseService = purchaseService
        _mediaModel.combine.send(model)
        bind()
    }

    deinit {
        updateTask?.cancel()
    }

    func onAppear() {
        Task {
            guard let shared = _mediaModel.combine.value else { return }

            let model = await storage.fetch(by: shared.id)
            if let model {
                _mediaModel.combine.send(model)
            }
            _isLiked.combine.send(model?.isFavorite ?? false)
            _isBookmarked.combine.send(model?.isBookmarked ?? false)
            _isSubscribed.combine.send(model?.isSubscribed ?? false)
            _canShowSubscribeButton.combine.send(
                canShowSubscribeButton(for: shared.releaseDate)
            )
        }
    }

    private func bind() {
        backTapped
            .sink { [weak self] _ in
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

        subscribeTapped
            .sink { [weak self] _ in
                self?.performPremiumAction(.subscribe)
            }
            .store(in: &bag)

        coordinator?.onPaywallDismiss = { [weak self] in
            self?.continuePendingPremiumActionIfNeeded()
        }
    }

    private func toggleLike() {
        updateModel(
            mutate: { $0.isFavorite.toggle() },
            updateState: { [weak self] model in
                self?._isLiked.combine.value = model.isFavorite
            }
        )
    }

    private func toggleBookmark() {
        updateModel(
            mutate: { $0.isBookmarked.toggle() },
            updateState: { [weak self] model in
                self?._isBookmarked.combine.value = model.isBookmarked
            }
        )
    }

    private func toggleSubscribe() {
        updateModel(
            mutate: { $0.isSubscribed.toggle() },
            updateState: { [weak self] model in
                self?._isSubscribed.combine.value = model.isSubscribed
            }
        )
    }

    private func updateModel(
        mutate: (inout MovieDTO) -> Void,
        updateState: @escaping (MovieDTO) -> Void
    ) {
        guard var model = _mediaModel.combine.value else { return }

        mutate(&model)
        _mediaModel.combine.send(model)
        updateState(model)

        updateTask?.cancel()
        updateTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
                try Task.checkCancellation()
                try await self?.dataWorker.updateOrDelete(dto: model)

                await MainActor.run { [self, model] in
                    self?._mediaModel.combine.send(model)
                    updateState(model)
                }
            } catch is CancellationError {
                return
            } catch {
                return
            }
        }
    }

    private func canShowSubscribeButton(for releaseDate: String?) -> Bool {
        guard let releaseDate else { return false }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: releaseDate) else {
            return false
        }

        return Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
    }

    private func handlePremiumAction(_ action: PremiumAction) {
        switch action {
        case .like:
            toggleLike()
        case .bookmark:
            toggleBookmark()
        case .subscribe:
            toggleSubscribe()
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
                guard isPremium, let action = self.pendingPremiumAction else { return }

                self.pendingPremiumAction = nil
                self.handlePremiumAction(action)
            }
        }
    }
}
