//
//  LineTextField.swift
//  NetflixProject
//
//  Created by George Popkich on 30.03.26.
//

import UIKit
import SnapKit

protocol LineTextFieldDelegate: AnyObject {

    func lineTextField(
        _ textField: LineTextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool

}

final class LineTextField: UIView {

    private enum Const {
        static let height: CGFloat = 64.0
    }

    private lazy var textField: UITextField = {
        let textField = UITextField()

        textField.textColor = .appTextFieldPrimary
        textField.font = FontFamily.Roboto.bold.font(size: 16.0)
        textField.textAlignment = .left

        textField.backgroundColor = .appTextFieldBg
        textField.layer.cornerRadius = 8.0
        textField.clipsToBounds = true

        textField.layer.borderColor = UIColor.appGray1.cgColor
        textField.layer.borderWidth = 1.0

        textField.attributedPlaceholder = NSAttributedString(
            string: "",
            attributes: [
                .foregroundColor: UIColor.appDisable,
                .font: FontFamily.Roboto.bold.font(size: 16.0)
            ]
        )

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always

        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.tintColor = .appGray3

        textField.delegate = self
        return textField
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = FontFamily.Roboto.bold.font(size: 16.0)
        label.textColor = .appActionRed
        label.textAlignment = .left
        return label
    }()

    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }

    var placeholder: String? {
        get { textField.placeholder}
        set { textField.placeholder = newValue }
    }

    var errorText: String? {
        get { errorLabel.text }
        set { errorLabel.text = newValue }
    }

    var borderStyle: UITextField.BorderStyle? {
        get { textField.borderStyle }
        set { textField.borderStyle = newValue ?? .none }
    }

    var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }

    var isSecure: Bool {
        get { textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }

    weak var delegate: LineTextFieldDelegate?

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupPlaceholder(_ text: String, color: UIColor) {
        textField.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [.foregroundColor: color]
        )
    }

    private func commonInit() {
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        addSubview(textField)
        addSubview(errorLabel)
        textField.cornerRadius = 8.0
    }

    private func setupConstraints() {
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(Const.height)
        }
        errorLabel.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.top.equalTo(textField.snp.bottom).inset(-4.0)
        }
    }

}

extension LineTextField: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        return delegate?.lineTextField(
            self,
            shouldChangeCharactersIn: range,
            replacementString: string
            ) ?? true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
