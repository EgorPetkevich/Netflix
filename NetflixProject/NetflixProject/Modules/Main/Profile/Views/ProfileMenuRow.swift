//
//  ProfileMenuRow.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 23.04.26.
//

import SwiftUI

struct ProfileMenuRow: View {
    private enum Const {
        static let iconSize: CGFloat = 32.0
    }

    let icon: String
    let color: Color
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appWhite)
                    .frame(width: Const.iconSize, height: Const.iconSize)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(title)
                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 16))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
