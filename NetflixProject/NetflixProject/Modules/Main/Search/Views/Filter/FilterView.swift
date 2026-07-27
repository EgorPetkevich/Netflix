//
//  FilterView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 21.04.26.
//

import SwiftUI
import ComposableArchitecture

struct FilterView: View {
    let store: StoreOf<FilterFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(L10n.mainSearchFilterTitle)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 32))
                    .foregroundColor(.appTextPrimary)
                Spacer()

            }
            .padding(.horizontal)
            .padding(.top, 20)

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(SearchType.allCases, id: \.self) { type in
                        filterButton(
                            title: type.displayName,
                            type: type
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.appBg.ignoresSafeArea())
    }

    private func filterButton(title: String, type: SearchType) -> some View {
        let isSelected = store.selectedType == type

        return Button(action: { store.send(.selectType(type)) }) {
                HStack {
                    Text(title)
                        .font(FontFamily.Roboto.medium.swiftUIFont(size: 18))

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .transition(.scale.combined(with: .opacity))
                        .foregroundStyle(isSelected ? .white : .appDisable)
                }
                .padding(.horizontal, 20)
                .frame(height: 60)
                .foregroundColor(isSelected ? .white : .appTextPrimary)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.appActionRed : Color.appActionRed.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.clear : Color.appActionRed.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
