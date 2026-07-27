//
//  DetailsView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 22.04.26.
//

import SwiftUI
import ComposableArchitecture
import Storage

struct DetailsView: View {

    let container: Container

    @Bindable var store: StoreOf<DetailsFeature>

    var body: some View {
        Group {
            if let model = store.model {
                switch model {

                case let person as PersonDTO:
                    PersonDetailsView(
                        container: container,
                        store: store,
                        person: person
                    )

                case let tv as TvDTO:
                    TvDetailsUIKitView(
                        container: container,
                        model: tv,
                        onFinish: {
                            store.send(.closeButtonTapped)
                        }
                    )

                case let movie as MovieDTO:
                    MovieDetailsUIKitView(
                        container: container,
                        model: movie,
                        onFinish: {
                            store.send(.closeButtonTapped)
                        }
                    )
                default:
                    EmptyView()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea()
    }
}
