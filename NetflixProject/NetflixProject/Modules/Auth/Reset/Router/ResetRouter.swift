//
//  ResetRouter.swift
//  NetflixProject
//
//  Created by George Popkich on 7.04.26.
//

import UIKit

final class ResetRouter: ResetRouterProtocol {

    weak var rootVC: UIViewController?

    func finsh() {
        rootVC?.dismiss(animated: true)
    }

}
