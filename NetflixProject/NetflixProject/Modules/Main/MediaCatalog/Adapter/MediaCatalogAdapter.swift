//
//  MediaCatalogAdapter.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 15.04.26.
//

import UIKit
import Combine
import Storage

final class MediaCatalogAdapter: NSObject, MediaCatalogAdapterProtocol {

    private enum Const {
        static let itemsInRow: CGFloat = 2.0
        static let leftInset: CGFloat = 8.0
        static let rightInset: CGFloat = 8.0
        static let interItemSpacing: CGFloat = 4.0
    }

    var items: CurrentValueSubject<[any MediaDTODescription], Never> = .init([])

    @Passthrough
    var didSelectItem: AnyPublisher<any MediaDTODescription, Never>

    @Passthrough
    var didScrollToEnd: AnyPublisher<Void, Never>

    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 8.0

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .clear

        return cv
    }()

    private var bag: Set<AnyCancellable> = []

    override init() {
        super.init()
        setupCollection()
        bind()
    }

    private func setupCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(MediaCell.self)
    }

    private func bind() {
        items
            .receive(on: DispatchQueue.main)
            .sink { [collectionView] _ in collectionView.reloadData() }
            .store(in: &bag)
    }

}

extension MediaCatalogAdapter: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return items.value.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let models = items.value

        let cell: MediaCell = collectionView.dequeue(at: indexPath)
        cell.setup(models[indexPath.item])

        return cell
    }

}

extension MediaCatalogAdapter: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        _didSelectItem.combine.send(items.value[indexPath.item])
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if indexPath.item == items.value.count - 1 {
            _didScrollToEnd.combine.send(())
        }
    }

}

extension MediaCatalogAdapter: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let leftInset: CGFloat = Const.leftInset
        let rightInset: CGFloat = Const.rightInset
        let interItemSpacing: CGFloat = Const.interItemSpacing

        let totalSpacing = interItemSpacing * 2
        let totalInsets = leftInset + rightInset

        let availableWidth = collectionView.bounds.width - totalInsets - totalSpacing

        let itemWidth = floor(availableWidth / Const.itemsInRow)

        let itemHeight = itemWidth * 1.5

        return CGSize(width: itemWidth, height: itemHeight)
    }
}
