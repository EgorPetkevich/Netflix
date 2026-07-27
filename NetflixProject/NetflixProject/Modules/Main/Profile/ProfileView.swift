//
//  ProfileView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 23.04.26.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {

    private enum Const {
        static let profileImageSize: CGFloat = 100.0
        static let bottomPadding: CGFloat = 100
    }

    let container: Container

    var onLogout: (() -> Void)?
    var onOpenFavorite: (() -> Void)?

    @Bindable var store: StoreOf<ProfileFeature>

    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    statsSection
                    menuSection
                    logoutButton
                }
                .padding(.vertical, 24)
                .padding(.bottom, Const.bottomPadding)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        } destination: { store in
            switch store.case {
            case let .bookmark(store):
                BookmarksView(store: store)
            case let .notifications(store):
                NotificationsView(store: store)
            case let .details(store):
                DetailsView(container: container, store: store)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onReceive(store.publisher) { state in
            if state.isLoggedOut {
                onLogout?()
            }
            if state.openFavoriteTrigger {
                onOpenFavorite?()
            }
        }
        .onChange(of: store.openFavoriteTrigger) { _, value in
            guard value else { return }
            onOpenFavorite?()
            store.openFavoriteTrigger = false
        }
        .sheet(isPresented: $store.openMailTrigger) {
            MailView()
        }
        .alert(
            $store.scope(
                state: \.destination?.alert,
                action: \.destination.alert
            )
        )
    }
}

// MARK: - Subviews
private extension ProfileView {

    var headerSection: some View {
        VStack(spacing: 12) {
            Image(.authHappyNetflixProfile)
                .resizable()
                .scaledToFit()
                .frame(
                    width: Const.profileImageSize,
                    height: Const.profileImageSize
                )

            VStack(spacing: 4) {
                Text(store.name)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 20))
                    .foregroundColor(.appTextPrimary)

                Text(store.email)
                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 16))
                    .foregroundColor(.secondary)
            }
        }
    }

    var statsSection: some View {
        HStack(spacing: 0) {
            ProfileStatItemView(
                title: L10n.mainProfileStatsFavorites,
                value: "\(store.favoritesCount)"
            )
            .onTapGesture {
                store.send(.favoritesTapped)
            }
            Divider().frame(height: 40)

            ProfileStatItemView(
                title: L10n.mainProfileStatsWaiting,
                value: "\(store.waitingsCount)"
            )
            .onTapGesture {
                store.send(.notificationsTapped)
            }
            Divider().frame(height: 40)

            ProfileStatItemView(
                title: L10n.mainProfileStatsMarked,
                value: "\(store.markedCount)"
            )
            .onTapGesture {
                store.send(.markedTapped)
            }
        }
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    var menuSection: some View {
        VStack(spacing: 0) {

            ProfileThemePickerRow(selectedTheme: $store.selectedTheme)

            Divider().padding(.leading, 52)

            ProfileMenuRow(
                icon: "bell.fill",
                color: .red,
                title: L10n.mainMenuNotifications,
                action: { store.send(.notificationsTapped) }
            )

            Divider().padding(.leading, 52)

            ProfileMenuRow(
                icon: "star.fill",
                color: .yellow,
                title: L10n.mainMenuRateApp,
                action: { store.send(.rateAppTapped) }
            )

            Divider().padding(.leading, 52)

            ProfileMenuRow(
                icon: "questionmark.circle.fill",
                color: .blue,
                title: L10n.mainMenuSupport,
                action: { store.send(.supportTapped) }
            )
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    var logoutButton: some View {
        Button {
            store.send(.logoutButtonTapped)
        } label: {
            Text(L10n.mainLogoutButton)
                .font(FontFamily.Roboto.medium.swiftUIFont(size: 20))
                .foregroundColor(.appActionRed)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
