//
//  ProfileThemePickerRow.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 23.04.26.
//

import SwiftUI

struct ProfileThemePickerRow: View {
    @Binding var selectedTheme: AppTheme

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "moon.fill")
                .font(FontFamily.Roboto.medium.swiftUIFont(size: 16))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.purple)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(L10n.mainProfileMenuTheme)
                .font(FontFamily.Roboto.regular.swiftUIFont(size: 16))
                .foregroundColor(.primary)

            Spacer()

            Picker(L10n.mainProfileMenuTheme, selection: $selectedTheme) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Text(theme.rawValue).tag(theme)
                }
            }
            .pickerStyle(.menu)
            .tint(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}
