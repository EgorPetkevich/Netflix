//
//  TvDetailsUIKitView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 8.05.26.
//

import SwiftUI
import Storage

struct TvDetailsUIKitView: UIViewControllerRepresentable {
    let container: Container
    let model: TvDTO
    let onFinish: () -> Void

    class RepresentableCoordinator {
        var detailsCoordinator: TvDetailsCoordinator?
    }

    func makeCoordinator() -> RepresentableCoordinator {
        return RepresentableCoordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let coordinator = TvDetailsCoordinator(container: container)

        coordinator.onDidFinish = { _ in
            self.onFinish()
        }

        context.coordinator.detailsCoordinator = coordinator

        return TvDetailsAssembler.make(
            container: container,
            model: model,
            coordinator: coordinator
        )
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) { }
}
