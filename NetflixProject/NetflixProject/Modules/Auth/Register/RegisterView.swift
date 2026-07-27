//
//  RegisterView.swift
//  NetflixProject
//
//  Created by George Popkich on 2.04.26.
//

import SwiftUI

struct RegisterView: View {

    private enum Const {
        static let maxEmailCharacters: Int = 100
        static let maxPasswordCharacters: Int = 64

        static let topPadding: CGFloat = 21.0
        static let horizontalPadding: CGFloat = 32.0
        static let loginButtonHeight: CGFloat = 64.0
        static let registerCornerRadius: CGFloat = 8.0
    }

    @StateObject private var viewModel: RegisterVM

    init(viewModel: RegisterVM) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {
            header
            Spacer()
            titleView
            form
        }
        .padding(.bottom, keyboardOffset)
        .background(.appBg)
        .toolbar(.hidden, for: .navigationBar)
        .onTapGesture { UIApplication.shared.hideKeyboard() }
        .animation(.easeOut(duration: 0.25), value: viewModel.isKeyBoardShowing)
    }
}

// MARK: - Subviews
private extension RegisterView {

    var header: some View {
        VStack(spacing: 8) {
            Image(.authLogoNetflix)
                .aspectRatio(contentMode: .fit)
                .padding(.top, Const.topPadding)
        }
        .opacity(isKeyboardHidden ? 1 : 0)
    }

    var titleView: some View {
        Text(L10n.authRegisterCreateAccount)
            .font(.custom(FontFamily.Roboto.bold.name, fixedSize: 40))
            .multilineTextAlignment(.leading)
            .foregroundStyle(.appTextPrimary)
            .opacity(isKeyboardHidden ? 1 : 0)
    }

    var form: some View {
        VStack(spacing: 12) {
            textField(
                text: $viewModel.emailText,
                error: $viewModel.emailErrorText,
                title: L10n.authRegisterEmailPlaceholder,
                keyboard: .emailAddress,
                onChange: { $0.count < Const.maxEmailCharacters }
            )

            textField(
                text: $viewModel.passwordText,
                error: $viewModel.passwordErrorText,
                title: L10n.authRegisterPasswordPlaceholder,
                isSecure: true,
                onChange: { $0.count < Const.maxPasswordCharacters }
            )

            textField(
                text: $viewModel.repeatPassText,
                error: $viewModel.repeatPassErrorText,
                title: L10n.authRegisterRepeatPasswordPlaceholder,
                isSecure: true,
                onChange: { $0.count < Const.maxPasswordCharacters }
            )

            alreadyHaveAccButton
            registerButton
        }
        .padding(.horizontal, Const.horizontalPadding)
        .padding(.vertical, 16)
    }

    func textField(
        text: Binding<String>,
        error: Binding<String?>,
        title: String,
        isSecure: Bool = false,
        keyboard: UIKeyboardType = .default,
        onChange: ((String) -> Bool)? = nil
    ) -> some View {
        LineTextFieldView(
            text: text,
            errorText: error,
            handleSecure: isSecure,
            title: title,
            placeholder: title,
            keyboardType: keyboard,
            onChange: onChange
        )
    }

    var registerButton: some View {
        Button(action: viewModel.registerButtonDidTap) {
            Text(L10n.authRegisterButton)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.appWhite)
                .frame(maxWidth: .infinity)
                .frame(height: Const.loginButtonHeight)
                .background(Color.appActionRed)
                .cornerRadius(Const.registerCornerRadius)
        }
    }

    var alreadyHaveAccButton: some View {
        HStack {
            Spacer()
            Button(action: viewModel.alreadyHaveAccButtonDidTap) {
                Text(L10n.authRegisterAlreadyHaveAccount)
                    .font(.custom(FontFamily.Roboto.medium.name, fixedSize: 16))
                    .foregroundStyle(.appDisable)
            }
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Halpers
private extension RegisterView {

    var isKeyboardHidden: Bool {
        !viewModel.isKeyBoardShowing
    }

    var keyboardOffset: CGFloat {
        viewModel.isKeyBoardShowing ? -30 : 0
    }
}
