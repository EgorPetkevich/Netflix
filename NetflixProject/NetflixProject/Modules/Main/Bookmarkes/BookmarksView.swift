//
//  BookmarksView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 30.04.26.
//

import SwiftUI
import ComposableArchitecture

struct BookmarksView: View {

    @Bindable var store: StoreOf<BookmarksFeature>

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBarView(
                title: L10n.mainBookmarkNavTitle,
                onBackTapped: {
                    store.send(.backButtonTapped)
                }
            )

            VStack(spacing: 16) {
                BookmarksGridView(store: store)
            }
            .padding(.top, 16)

            Spacer()
        }
        .background(Color.appBg)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            store.send(.onAppear)
        }
    }
}
