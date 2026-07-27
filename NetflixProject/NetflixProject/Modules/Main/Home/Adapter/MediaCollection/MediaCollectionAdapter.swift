//
//  MediaListAdapter.swift
//  NetflixProject
//
//  Created by George Popkich on 8.04.26.
//

import UIKit
import Combine
import Storage

final class MediaCollectionAdapter: NSObject {

    private enum Const {
        static let itemWidth: CGFloat = 120.0
    }

    var items = CurrentValueSubject<[any MediaDTODescription], Never>([])

    @Passthrough
    var didSelectItem: AnyPublisher<any MediaDTODescription, Never>

    @Passthrough
    var didScrollToEnd: AnyPublisher<MediaSectionType, Never>

    @Passthrough
    var offsetSubject: AnyPublisher<(MediaSectionType, CGPoint), Never>

    @Passthrough
    var showAllTapped: AnyPublisher<(MediaSectionType), Never>

    var sectionType: MediaSectionType?

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        cv.showsHorizontalScrollIndicator = false
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
        collectionView.register(ShowAllCell.self)
    }

    private func bind() {
        items
            .receive(on: DispatchQueue.main)
            .sink { [collectionView] _ in collectionView.reloadData() }
            .store(in: &bag)
    }

}

extension MediaCollectionAdapter: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return items.value.count + 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let models = items.value

        if indexPath.item == models.count {
            let cell: ShowAllCell = collectionView.dequeue(at: indexPath)
            return cell
        }

        let cell: MediaCell = collectionView.dequeue(at: indexPath)
        cell.setup(models[indexPath.item])

        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            guard let type = sectionType else { return }
            _offsetSubject.combine.send((type, scrollView.contentOffset))
        }
    }
}

extension MediaCollectionAdapter: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let models = items.value

        if indexPath.item == models.count, let sectionType {
            _showAllTapped.combine.send(sectionType)
            return
        }
        _didSelectItem.combine.send(items.value[indexPath.item])
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if indexPath.item == items.value.count - 1 {
            guard let sectionType else { return }
            _didScrollToEnd.combine.send(sectionType)
        }
    }
}

extension MediaCollectionAdapter: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: Const.itemWidth, height: collectionView.frame.height)
    }
}
