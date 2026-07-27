//
//  PaywallFeatureRow.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 14.05.26.
//

import SwiftUI

struct PaywallFeatureRow: View {

    let title: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.appActionRed)

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
        }
    }
}
