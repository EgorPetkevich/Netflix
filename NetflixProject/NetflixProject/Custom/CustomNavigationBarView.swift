//
//  CustomNavigationBarView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 8.05.26.
//

import SwiftUI

struct CustomNavigationBarView: View {
    var title: String
    var onBackTapped: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.custom("Roboto-Bold", size: 18.0))
                .foregroundColor(.appGray3)
                .multilineTextAlignment(.center)

            HStack {
                Button(action: onBackTapped) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appActionRed)
                        .frame(width: 40, height: 40)
                }
                .padding(.leading, 8)

                Spacer()
            }
        }
        .frame(height: 40)
        .background(Color.appBg)
    }
}
