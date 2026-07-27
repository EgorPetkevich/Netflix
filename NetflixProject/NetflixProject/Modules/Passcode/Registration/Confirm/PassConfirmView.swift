//
//  PassConfirmView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 7.05.26.
//

import SwiftUI

struct PassConfirmView: View {

    @StateObject private var viewModel: PassConfirmViewModel

    init(viewModel: PassConfirmViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            headerView
            pinIndicatorsView
            Spacer()
            keypadSection
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.backButtonTapped()
                }) {
                    backButton
                }
            }
        }
    }

    private var backButton: some View {
        Image(systemName: "chevron.left")
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.primary)
    }

    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 40))

            Text(L10n.authPinConfirmPin)
                .font(.title2)
                .fontWeight(.semibold)

            Text(viewModel.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var pinIndicatorsView: some View {
        HStack(spacing: 20) {
            ForEach(0..<viewModel.pinLength, id: \.self) { index in
                Circle()
                    .fill(index < viewModel.pin.count ? Color.primary : Color.clear)
                    .frame(width: 16, height: 16)
                    .overlay {
                        Circle()
                            .stroke(Color.primary, lineWidth: 1.5)
                    }
            }
        }
    }

    private var keypadSection: some View {
        KeypadView(
            pin: $viewModel.pin,
            pinLength: viewModel.pinLength
        )
        .padding(.horizontal, 40)
        .padding(.bottom, 50)
    }
}
