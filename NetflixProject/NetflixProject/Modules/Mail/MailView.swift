//
//  MailView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 12.05.26.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {

    let recipients: [String] = ["netflix@gmail.com"]
    let subject: String = "Netflix"
    let body: String = "Hello, I need assistance with your application."
    let isHTML: Bool = false

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = context.coordinator
        mail.setToRecipients(recipients)
        mail.setSubject(subject)
        mail.setMessageBody(body, isHTML: isHTML)
        return mail
    }

    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            dismiss()
        }
    }
}
