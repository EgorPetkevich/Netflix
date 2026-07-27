//
//  UIApplication+FirstResponder.swift
//  NetflixProject
//
//  Created by George Popkich on 2.04.26.
//

import UIKit

extension UIApplication {

    func hideKeyboard() {
        sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

}
