//
//  FavoritesView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 24.04.26.
//

import SwiftUI
import ComposableArchitecture

struct FavoritesView: View {

    let container: Container

    @Bindable var store: StoreOf<FavoritesFeature>

    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            VStack(spacing: 16) {
                FavoritesSegmentedControl(store: store)
                FavoritesGridView(store: store)
            }
            .padding(.top, 16)
            .background(.appBg)
            .onAppear {
                store.send(.onAppear)
            }
        } destination: { store in
            switch store.case {
            case let .details(store):
                DetailsView(container: container, store: store)
            }
        }
    }
}
