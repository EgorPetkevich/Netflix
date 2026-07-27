//
//  MediaRow.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 20.04.26.
//

import SwiftUI
import Kingfisher

struct MediaRow: View {
    let title: String
    let subtitle: String
    let imageUrl: String?

    var body: some View {
        HStack(spacing: 16) {

            Group {
                if let imageUrl,
                   let url = URLBuilder.image(type: .poster(path: imageUrl)) {
                    KFImage(url)
                        .resizable()
                        .placeholder { _ in
                            Color.gray.opacity(0.2)
                        }
                } else {
                    Color.gray.opacity(0.2)
                        .overlay(
                            Image(systemName: "film")
                                .foregroundColor(.gray)
                        )
                }
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 80)
            .clipped()
            .cornerRadius(6)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 16.0))
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 14.0))
                    .foregroundColor(.appGray3)
                    .lineLimit(2)
            }

            Spacer()

        }
        .padding(.vertical, 8)
        .background(.clear)
    }
}
