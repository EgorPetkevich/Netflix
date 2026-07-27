//
//  ProfileStatItemView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 23.04.26.
//

import SwiftUI

struct ProfileStatItemView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 16))
                .foregroundColor(.appTextPrimary)
            Text(title)
                .font(FontFamily.Roboto.regular.swiftUIFont(size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
