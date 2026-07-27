//
//  FavoritesSegmentedControl.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 24.04.26.
//

import SwiftUI
import ComposableArchitecture

enum FavoritesFilter: String, CaseIterable, Equatable {
    case movies = "Movies"
    case tvs = "TVs"
    case persons = "Persons"
}

struct FavoritesSegmentedControl: View {

    @Bindable var store: StoreOf<FavoritesFeature>

    var body: some View {
        HStack {
            ForEach(FavoritesFilter.allCases, id: \.self) { filter in
                Button {
                    store.send(.filterChanged(filter))
                } label: {
                    Text(filter.rawValue)
                        .font(FontFamily.Roboto.medium.swiftUIFont(size: 16.0))
                        .foregroundColor(
                            store.selectedFilter == filter ? .appWhite : .appDisable
                        )
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            store.selectedFilter == filter
                            ? Color.appActionRed
                            : Color.clear
                        )
                        .cornerRadius(8)
                }
            }
        }
        .background(.appBg)
        .padding(.horizontal)
    }
}
