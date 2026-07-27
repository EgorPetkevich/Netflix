//
//  Coordinator.swift
//  NetflixProject
//
//  Created by George Popkich on 26.03.26.
//

import UIKit

class Coordinator {

    var onDidFinish: ((Coordinator) -> Void)?

    var children: [Coordinator] = []

    func start() -> UIViewController {
        fatalError("Start should be overiden")
    }

    func finish() {
        onDidFinish?(self)
    }

}
