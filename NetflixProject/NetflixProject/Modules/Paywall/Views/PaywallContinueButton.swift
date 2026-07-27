//
//  PaywallContinueButton.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 14.05.26.
//

import SwiftUI

struct PaywallContinueButton: View {

    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(L10n.paywallContinue)
                        .font(.system(size: 17, weight: .bold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(.appActionRed)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .disabled(isLoading)
    }
}
