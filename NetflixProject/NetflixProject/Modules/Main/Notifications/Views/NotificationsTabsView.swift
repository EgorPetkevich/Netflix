//
//  NotificationsTabsView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 12.05.26.
//

import SwiftUI
import ComposableArchitecture

enum NotificationTab: CaseIterable, Identifiable {
    case waitings
    case delivered

    var id: Self { self }

    var title: String {
        switch self {
        case .waitings:
            return L10n.mainNotificationsWaitings
        case .delivered:
            return L10n.mainNotificationsDelivered
        }
    }
}

struct NotificationsTabsView: View {

    @Bindable var store: StoreOf<NotificationsFeature>

    var body: some View {
        Picker(
            L10n.mainNotifications,
            selection: Binding(
                get: { store.selectedTab },
                set: { store.send(.tabSelected($0)) }
            )
        ) {
            ForEach(NotificationTab.allCases) { tab in
                Text(tab.title)
                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 16.0))
                    .tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

}
