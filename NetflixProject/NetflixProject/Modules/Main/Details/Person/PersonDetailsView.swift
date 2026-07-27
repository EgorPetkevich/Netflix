//
//  PersonDetailsView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 22.04.26.
//

import SwiftUI
import ComposableArchitecture
import Storage

struct PersonDetailsView: View {

    private enum Const {
        static let profileImageHeight: CGFloat = 400
        static let bottomPadding: CGFloat = 100
    }

    let container: Container

    @Bindable var store: StoreOf<DetailsFeature>

    let person: PersonDTO

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    StretchyHeader(profilePath: person.posterPath)

                    content
                        .padding(.top, 16)
                }
            }
            .ignoresSafeArea(edges: .top)

            customNavBar
        }
        .statusBar(hidden: true)
        .onAppear {
            store.send(.onAppear)
        }
        .fullScreenCover(
            item: $store.scope(
                state: \.destination?.paywall,
                action: \.destination.paywall
            )
        ) { paywallStore in
            PaywallView(store: paywallStore)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection
            metaSection
            departmentSection
            Divider()
            knownForSection
        }
        .padding(.bottom, Const.bottomPadding)
    }

    private var customNavBar: some View {
        HStack {
            Button {
                store.send(.closeButtonTapped)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(uiColor: .systemRed))
                    .frame(width: 32, height: 32)
                    .background(Color.black.opacity(0.4), in: Circle())
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 40)
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 20))
                    .foregroundStyle(.appTextPrimary)

                if person.originalName != person.name {
                    Text(person.originalName)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            actionButtonsSection
        }
        .padding(.horizontal)
    }

    private var actionButtonsSection: some View {
        HStack(spacing: 20) {
            Button(action: { store.send(.likeButtonTapped) }) {
                Image(systemName: store.model?.isFavorite ?? false ? "heart.fill" : "heart")
                    .font(.system(size: 20))
                    .foregroundColor(Color(uiColor: .systemRed))
                    .frame(width: 20, height: 40)
            }

            Button(action: { store.send(.bookmarkButtonTapped) }) {
                Image(systemName: store.model?.isBookmarked ?? false ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 20))
                    .foregroundColor(.appRateYellow)
                    .frame(width: 20, height: 40)
            }
        }
        .padding(.horizontal, 16)
    }

    private var metaSection: some View {
        HStack(spacing: 16) {

            if let popularity = person.popularity {
                Label(
                    popularity.formattedPopularity,
                    systemImage: "star.fill"
                )
                .foregroundColor(.yellow)
            }

            if let gender = person.gender {
                Text(gender.genderText())
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var departmentSection: some View {
        if let department = person.knownForDepartment {
            Text("Known for: \(department)")
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var knownForSection: some View {
        Text("Known For")
            .font(FontFamily.Roboto.bold.swiftUIFont(size: 20))
            .padding(.horizontal)

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(person.knownFor, id: \.id) { knownFor in

                    Button {
                        store.send(.itemTapped(knownFor))
                    } label: {
                        KnownForCard(model: knownFor)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}
