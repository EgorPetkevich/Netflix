//
//  FavoritesGridView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 24.04.26.
//

import SwiftUI
import ComposableArchitecture

struct FavoritesGridView: View {

    @Bindable var store: StoreOf<FavoritesFeature>

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
            Image(systemName: "heart.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.8))

            Text(L10n.mainFavoritesNoFavoritesTitle)
                .font(FontFamily.Roboto.medium.swiftUIFont(size: 20))
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text(L10n.mainFavoritesNoFavoritesSubtitle)
                .font(FontFamily.Roboto.regular.swiftUIFont(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
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
                        FavoritesItemView(model: model)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}
