//
//  PaywallFeature.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 14.05.26.
//

import SwiftUI
import StoreKit
import ComposableArchitecture

@Reducer
struct PaywallFeature {

    @ObservableState
    struct State: Equatable {
        var selectedProduct: PurchaseProduct?
        var isLoading = false
        var errorMessage: String?
        var isErrorAlertPresented = false
        var products: [PurchaseProduct] = []
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case closeButtonTapped
        case productSelected(PurchaseProduct)
        case continueButtonTapped
        case restoreButtonTapped
        case termsTapped
        case privacyTapped
        case onAppear
        case productsLoaded([PurchaseProduct])
        case productsLoadingFailed(String)
        case purchaseFinished
        case purchaseFailed(String)
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.isPresented) var isPresented
    @Dependency(\.purchaseService) private var purchaseService

    private let onClose: @MainActor () -> Void

    init(onClose: @escaping @MainActor () -> Void = {}) {
        self.onClose = onClose
    }

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {

            case .binding:
                return .none

            case .closeButtonTapped:
                return close()

            case .purchaseFinished:
                state.isLoading = false
                return close()

            case let .productSelected(product):
                state.selectedProduct = product
                return .none

            case .onAppear:
                state.isLoading = true

                return .run { send in
                    do {
                        let products = try await purchaseService.fetchProducts()
                        await send(.productsLoaded(products))
                    } catch {
                        await send(.productsLoadingFailed(error.localizedDescription))
                    }
                }

            case let .productsLoaded(products):
                state.isLoading = false
                state.products = products
                state.selectedProduct = state.selectedProduct ?? products.first
                return .none

            case let .productsLoadingFailed(message):
                state.isLoading = false
                state.errorMessage = message
                state.isErrorAlertPresented = true
                return .none

            case .continueButtonTapped:
                guard let productId = state.selectedProduct?.productId else {
                    state.errorMessage = "Product not selected"
                    state.isErrorAlertPresented = true
                    return .none
                }

                state.isLoading = true
                state.errorMessage = nil

                return .run { send in
                    do {
                        try await purchaseService.purchase(productId: productId)
                        await send(.purchaseFinished)
                    } catch {
                        await send(.purchaseFailed(error.localizedDescription))
                    }
                }

            case .restoreButtonTapped:
                state.isLoading = true
                state.errorMessage = nil

                return .run { send in
                    do {
                        try await purchaseService.restorePurchases()
                        await send(.purchaseFinished)
                    } catch {
                        await send(.purchaseFailed(error.localizedDescription))
                    }
                }

            case let .purchaseFailed(message):
                state.isLoading = false
                state.errorMessage = message
                state.isErrorAlertPresented = true
                return .none

            case .termsTapped:
                return .none

            case .privacyTapped:
                return .none
            }
        }
    }

    private func close() -> Effect<Action> {
        .run { _ in
            if isPresented {
                await dismiss()
            } else {
                await MainActor.run {
                    onClose()
                }
            }
        }
    }
}
