//
//  MovieDetailsUIKitView.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 8.05.26.
//

import SwiftUI
import Storage

struct MovieDetailsUIKitView: UIViewControllerRepresentable {
    let container: Container
    let model: MovieDTO
    let onFinish: () -> Void

    class RepresentableCoordinator {
        var detailsCoordinator: MovieDetailsCoordinator?
    }

    func makeCoordinator() -> RepresentableCoordinator {
        return RepresentableCoordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let coordinator = MovieDetailsCoordinator(container: container)

        coordinator.onDidFinish = { _ in
            self.onFinish()
        }

        context.coordinator.detailsCoordinator = coordinator

        return MovieDetailsAssembler.make(
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
