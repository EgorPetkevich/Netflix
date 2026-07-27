//
//  UICollectionView+Register.swift
//  NetflixProject
//
//  Created by George Popkich on 8.04.26.
//

import UIKit

extension UICollectionView {

    func dequeue<CellType: UICollectionViewCell>(at indexPath: IndexPath) -> CellType {
        return self.dequeueReusableCell(
            withReuseIdentifier: "\(CellType.self)",
            for: indexPath
        ) as! CellType
    }

    func register<CellType: UICollectionViewCell>(_ type: CellType.Type) {
        self.register(type, forCellWithReuseIdentifier: "\(type.self)")
    }

}
