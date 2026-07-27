//
//  PassLoginView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 6.05.26.
//

import SwiftUI

struct PassLoginView: View {

    @StateObject private var viewModel: PassLoginViewModel

    init(viewModel: PassLoginViewModel) {
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
        .onChange(of: viewModel.pin) { _, _ in
            viewModel.verifyPinIfNeeded()
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundColor(.primary)

            Text(L10n.authPinEnterPasscode)
                .font(.title2)
                .fontWeight(.semibold)

            Text(viewModel.statusMessage)
                .font(.subheadline)
                .foregroundColor(viewModel.authStatus.statusColor)
        }
    }

    private var pinIndicatorsView: some View {
        HStack(spacing: 20) {
            ForEach(0..<viewModel.pinLength, id: \.self) { index in
                Circle()
                    .fill(
                        index < viewModel.pin.count ? Color.primary : Color.clear
                    )
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(Color.primary, lineWidth: 1.5)
                    )
            }
        }
        .animation(.easeInOut(duration: 0.1), value: viewModel.pin.count)
        .padding(.vertical, 20)
    }

    private var keypadSection: some View {
        KeypadView(
            pin: $viewModel.pin,
            pinLength: viewModel.pinLength,
            onFaceIdTap: { viewModel.retryFaceID() }
        )
        .padding(.horizontal, 40)
        .padding(.bottom, 50)
    }
}
