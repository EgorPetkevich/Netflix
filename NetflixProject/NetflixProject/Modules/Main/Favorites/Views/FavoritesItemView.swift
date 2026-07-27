//
//  FavoritesItemView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 24.04.26.
//

import SwiftUI
import Kingfisher
import Storage

struct FavoritesItemView: View {

    private enum Const {
        static let radius: CGFloat = 12
    }

    let model: any MediaDTODescription

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            imageSection
        }
        .contentShape(Rectangle())
    }

    private var imageSection: some View {
        ZStack(alignment: .bottom) {
            poster
            gradientOverlay
        }
        .clipShape(RoundedRectangle(cornerRadius: Const.radius))
    }

    private var titleSection: some View {
        Text(model.title)
            .font(FontFamily.Roboto.regular.swiftUIFont(size: 14))
            .lineLimit(2)
            .foregroundColor(.primary)
    }

    @ViewBuilder
    private var poster: some View {
        if let path = model.posterPath,
           let url = URLBuilder.image(type: .poster(path: path)) {

            KFImage(url)
                .placeholder { placeholder }
                .resizable()
                .scaledToFill()
        } else {
            placeholder
        }
    }

    private var gradientOverlay: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.6)],
            startPoint: .center,
            endPoint: .bottom
        )
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay {
                Image(systemName: "film")
                    .foregroundColor(.gray)
            }
    }

}
