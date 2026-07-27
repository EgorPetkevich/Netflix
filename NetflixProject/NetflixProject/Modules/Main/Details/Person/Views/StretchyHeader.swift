//
//  StretchHeader.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 23.04.26.
//

import SwiftUI
import Kingfisher

struct StretchyHeader: View {

    private enum Const {
        static let height: CGFloat = UIScreen.main.bounds.height * 0.7
    }

    let profilePath: String?

    var body: some View {
        GeometryReader { geo in

            let offset = geo.frame(in: .global).minY

            headerImage
                .frame(
                    width: geo.size.width,
                    height: height(for: offset)
                )
                .clipped()
                .offset(y: offset > 0 ? -offset : 0)
        }
        .frame(height: Const.height)
    }

    private func height(for offset: CGFloat) -> CGFloat {
        offset > 0 ? Const.height + offset : Const.height
    }

    private var headerImage: some View {
        Group {
            if let path = profilePath,
               let url = URLBuilder.image(
                type: .poster(path: path),
                size: .original
               ) {

                KFImage(url)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
            }
        }
    }
}
