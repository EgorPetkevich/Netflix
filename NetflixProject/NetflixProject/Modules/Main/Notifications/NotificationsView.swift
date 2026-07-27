//
//  NotificationsView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 11.05.26.
//

import SwiftUI
import ComposableArchitecture

struct NotificationsView: View {

    @Bindable var store: StoreOf<NotificationsFeature>

    var body: some View {
        VStack(spacing: 16) {
            CustomNavigationBarView(
                title: L10n.mainNotifications,
                onBackTapped: {
                    store.send(.backButtonTapped)
                }
            )
            NotificationsTabsView(store: store)
            NotificationsGridView(store: store)

            Spacer()
        }
        .background(Color.appBg)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            store.send(.onAppear)
        }
    }
}
