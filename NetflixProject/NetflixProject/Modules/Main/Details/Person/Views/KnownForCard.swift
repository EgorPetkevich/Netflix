//
//  KnownForCard.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 23.04.26.
//

import SwiftUI
import Kingfisher
import Storage

struct KnownForCard: View {

    private enum Const {
        static let size = CGSize(width: 120, height: 180)
        static let radius: CGFloat = 12
    }

    let model: any MediaDTODescription

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            imageSection
            titleSection
        }
        .contentShape(Rectangle())
    }

    private var imageSection: some View {
        ZStack(alignment: .bottom) {
            poster
            gradientOverlay
        }
        .frame(width: Const.size.width, height: Const.size.height)
        .clipShape(RoundedRectangle(cornerRadius: Const.radius))
    }

    private var titleSection: some View {
        Text(model.title)
            .font(FontFamily.Roboto.regular.swiftUIFont(size: 14))
            .lineLimit(2)
            .foregroundColor(.primary)
            .frame(width: Const.size.width, alignment: .leading)
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
