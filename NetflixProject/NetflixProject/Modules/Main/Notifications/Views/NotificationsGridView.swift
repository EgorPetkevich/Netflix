//
//  NotificationsGridView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 11.05.26.
//

import SwiftUI
import ComposableArchitecture

struct NotificationsGridView: View {

    @Bindable var store: StoreOf<NotificationsFeature>

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Group {
            if store.filteredItems.isEmpty {
                emptyStateView
            } else {
                gridView
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.8))

            Text(L10n.mainNoNotifications)
                .font(FontFamily.Roboto.medium.swiftUIFont(size: 20))
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text(L10n.mainNotificationErrorSubTitle)
                .font(FontFamily.Roboto.regular.swiftUIFont(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(store.filteredItems, id: \.id) { model in
                    Button {
                        store.send(.itemSelected(model))
                    } label: {
                        NotificationsItemView(model: model)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}
