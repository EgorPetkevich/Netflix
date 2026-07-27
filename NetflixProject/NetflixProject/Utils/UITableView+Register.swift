//
//  UITableView+Register.swift
//  NetflixProject
//
//  Created by George Popkich on 8.04.26.
//

import UIKit

extension UITableView {

    func dequeue<CellType: UITableViewCell>(at indexPath: IndexPath) -> CellType {
        return self.dequeueReusableCell(
            withIdentifier: "\(CellType.self)",
            for: indexPath
        ) as! CellType
    }

    func register<CellType: UITableViewCell>(_ type: CellType.Type) {
        self.register(type, forCellReuseIdentifier: "\(type.self)")
    }

}
