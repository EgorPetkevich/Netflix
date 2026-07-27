//
//  SearchView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 20.04.26.
//

import SwiftUI
import Lottie
import ComposableArchitecture
import Storage

struct SearchView: View {

    let container: Container

    @Bindable var store: StoreOf<SearchFeature>
    @FocusState private var focus: SearchFeature.State.Focus?

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack(spacing: 0) {
                if store.searchResults.isEmpty {
                    titleSection
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                searchBarSection
                    .padding(.vertical, 12)

                resultsListSection
                    .overlay {
                        if store.isLoading { loadingOverlay }
                    }
            }
            .background(Color.appBg.ignoresSafeArea())
            .onTapGesture { focus = nil }
            .alert(
                $store.scope(
                    state: \.destination?.alert,
                    action: \.destination.alert
                )
            )
            .sheet(
                item: $store.scope(
                    state: \.destination?.filter,
                    action: \.destination.filter
                )
            ) { filterStore in
                FilterView(store: filterStore)
                    .presentationDetents([.medium, .large])
            }
        } destination: { store in
            switch store.case {
            case let .details(store):
                DetailsView(container: container, store: store)
            }
        }
    }
}

// MARK: - Subviews
private extension SearchView {

    var titleSection: some View {
        Text(L10n.mainSearchTitle)
            .font(FontFamily.Roboto.bold.swiftUIFont(size: 35))
            .foregroundStyle(.appTextPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
    }

    var searchBarSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField(L10n.mainSearchTitle, text: $store.searchText)
                .submitLabel(.search)
                .focused($focus, equals: .search)
                .bind($store.focus, to: $focus)
                .onSubmit { store.send(.onSubmitTapped) }

            if !store.searchText.isEmpty {
                Button { store.send(.crossButtonTapped) } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }

            Button { store.send(.filterButtonTapped) } label: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.appDisable)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }

    var resultsListSection: some View {
        List(store.searchResults, id: \.id) { model in
            Button {
                store.send(.itemTapped(model))
            } label: {
                MediaRow(
                    title: model.title,
                    subtitle: model.overview,
                    imageUrl: model.posterPath
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .animation(.default, value: store.searchResults.map(\.id))
    }

    var loadingOverlay: some View {
        ZStack {
            Color.clear

            LottieView(animation: .named("loadAnimation"))
                .playing(loopMode: .loop)
                .frame(width: 150, height: 150)
        }
        .transition(.opacity.animation(.easeInOut))
    }
}
