//
//  PaywallPlanCell.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 15.05.26.
//

import SwiftUI

struct PaywallPlanCell: View {

    let product: PurchaseProduct
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {

                HStack(spacing: 12.0) {

                    Text(product.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(product.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    Text(product.price)
                        .font(.headline)
                        .foregroundColor(isSelected ? .appActionRed : .white)
                        .multilineTextAlignment(.trailing)
                }

                if let introText = product.introText {
                    Text(introText)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.green.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(
                isSelected
                ? Color.white.opacity(0.1)
                : Color.clear
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected
                        ? Color.appActionRed
                        : Color.white.opacity(0.4),
                        lineWidth: 1
                    )
            }
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}
