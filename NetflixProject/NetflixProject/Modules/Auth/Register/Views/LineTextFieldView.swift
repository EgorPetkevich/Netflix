//
//  LineTextFieldView.swift
//  NetflixProject
//
//  Created by George Popkich on 2.04.26.
//

import SwiftUI

struct LineTextFieldView: View {

    private enum Const {
        static let height: CGFloat = 64.0
        static let cornerRadius: CGFloat = 8.0
        static let borderWidth: CGFloat = 1.0
    }

    @State private var isSecure: Bool = true

    @Binding var text: String
    @Binding var errorText: String?

    var handleSecure: Bool

    var title: String = ""
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default

    var onChange: ((String) -> Bool)?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !title.isEmpty {
                titleView
            }
            inputContainer
            errorView
        }
    }
}

// MARK: - Subviews
private extension LineTextFieldView {

    var titleView: some View {
        Text(title)
            .font(.custom(FontFamily.Roboto.medium.name, fixedSize: 16))
            .foregroundColor(.appTextPrimary)
    }

    var inputContainer: some View {
            HStack(spacing: 10) {
                inputField
                    .font(.custom(FontFamily.Roboto.bold.name, fixedSize: 16))
                    .foregroundColor(.appTextFieldPrimary)

                secureToggleButton
            }
            .padding(.horizontal, 12)
            .frame(height: Const.height)
            .background(Color.appTextFieldBg)
            .cornerRadius(Const.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Const.cornerRadius)
                    .stroke(Color.appGray1, lineWidth: Const.borderWidth)
            )
            .tint(.appGray3)
            .keyboardType(keyboardType)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .onChange(of: text) { oldValue, newValue in
                handleTextChange(oldValue, newValue)
            }
        }

    var inputField: some View {
        Group {
            if isSecureEnabled {
                SecureField("", text: $text, prompt: placeholderView)
            } else {
                TextField("", text: $text, prompt: placeholderView)
            }
        }
    }

    var placeholderView: Text? {
        Text(placeholder)
            .foregroundColor(.appDisable)
    }

    var secureToggleButton: some View {
        Group {
            if handleSecure {
                Button(action: toggleSecure) {
                    Text(isSecure ? L10n.authLoginShowButton : L10n.authLoginHideButton)
                        .font(.custom(FontFamily.Roboto.bold.name, fixedSize: 14))
                        .foregroundStyle(.appGray3)
                }
            }
        }
    }

    var errorView: some View {
        Group {
            if let errorText, !errorText.isEmpty {
                Text(errorText)
                    .font(.custom(FontFamily.Roboto.bold.name, fixedSize: 14))
                    .foregroundColor(.appActionRed)
                    .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - Helpers
private extension LineTextFieldView {

    var isSecureEnabled: Bool {
        handleSecure && isSecure
    }

    func toggleSecure() {
        isSecure.toggle()
    }

    func handleTextChange(_ oldValue: String, _ newValue: String) {
        if let isAllowed = onChange?(newValue), !isAllowed {
            text = oldValue
        }
    }
}
