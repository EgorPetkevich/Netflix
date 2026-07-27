//  PaywallView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 14.05.26.
//

import SwiftUI
import ComposableArchitecture

struct PaywallView: View {

    @Bindable var store: StoreOf<PaywallFeature>

    var body: some View {
        ZStack {
            backgroundView
            topContentView
            contentView
        }
        .alert(
            "Error",
            isPresented: $store.isErrorAlertPresented
        ) {
            Button("OK") {
                store.send(.binding(.set(\.isErrorAlertPresented, false)))
            }
        } message: {
            Text(store.errorMessage ?? "Unknown error")
        }
        .onAppear {
            store.send(.onAppear)
        }
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [.appActionRed.opacity(0.75), .black, .black],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var contentView: some View {
        VStack(spacing: 24) {
            Spacer()
            centerContentView
            bottomContentView
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .ignoresSafeArea(edges: .bottom)
    }

    private var topContentView: some View {
        VStack(spacing: 0) {
            headerView
            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var centerContentView: some View {
        VStack(spacing: 24) {
            titleView
            featuresView
            plansView
        }
    }

    private var bottomContentView: some View {
        VStack(spacing: 24) {
            PaywallContinueButton(
                isLoading: store.isLoading,
                action: { store.send(.continueButtonTapped) }
            )
            bottomButtons
        }
    }

    private var headerView: some View {
        HStack {
            Spacer()

            Button {
                store.send(.closeButtonTapped)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.white.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 12)
    }

    private var titleView: some View {
        VStack(spacing: 12) {
            Text(L10n.paywallTitle)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)

            Text(L10n.paywallSubtitle)
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.75))
                .multilineTextAlignment(.center)
        }
    }

    private var featuresView: some View {
        VStack(alignment: .leading, spacing: 12) {
            PaywallFeatureRow(title: L10n.paywallFeatureReleases)
            PaywallFeatureRow(title: L10n.paywallFeatureNotifications)
            PaywallFeatureRow(title: L10n.paywallFeatureTrending)
            PaywallFeatureRow(title: L10n.paywallFeatureFavorites)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var plansView: some View {
        VStack(spacing: 12) {
            ForEach(store.products) { product in
                PaywallPlanCell(
                    product: product,
                    isSelected: store.selectedProduct == product,
                    action: { store.send(.productSelected(product)) }
                )
            }
        }
    }

    private var bottomButtons: some View {
        VStack(spacing: 8) {
            HStack(spacing: 26) {
                Button(L10n.paywallRestore) {
                    store.send(.restoreButtonTapped)
                }

                Button(L10n.paywallTerms) {
                    store.send(.termsTapped)
                }

                Button(L10n.paywallPrivacy) {
                    store.send(.privacyTapped)
                }
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white.opacity(0.65))
            .disabled(store.isLoading)

            Text(L10n.paywallDisclaimer)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }
}
