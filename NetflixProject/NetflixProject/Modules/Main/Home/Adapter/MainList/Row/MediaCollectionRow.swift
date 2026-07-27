//
//  MediaCollectionRow.swift
//  NetflixProject
//
//  Created by George Popkich on 8.04.26.
//

import UIKit
import SnapKit
import Combine
import Storage

final class MediaCollectionRow: UITableViewCell {

    private var type: MediaSectionType?

    @Passthrough
    var didSelectItem: AnyPublisher<any MediaDTODescription, Never>

    @Passthrough
    var didScrollToEnd: AnyPublisher<MediaSectionType, Never>

    @Passthrough
    var showAllTapped: AnyPublisher<(MediaSectionType), Never>

    private var collectionView: UICollectionView {
        adapter.collectionView
    }

    private var adapter = MediaCollectionAdapter()

    private var bag: Set<AnyCancellable> = []

    private var reuseBag: Set<AnyCancellable> = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        bind()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        bind()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reuseBag = []
    }

    func setup(_ section: MediaListSection, offset: CGPoint) {
        self.type = section.type
        adapter.sectionType = section.type
        adapter.items.send(section.media)

        collectionView.layoutIfNeeded()
        collectionView.setContentOffset(offset, animated: false)
    }

    func bind(to publisher: PassthroughSubject<any MediaDTODescription, Never>) {
        didSelectItem
            .subscribe(publisher)
            .store(in: &reuseBag)
    }

    func bind(to publisher: PassthroughSubject<MediaSectionType, Never>) {
        didScrollToEnd
            .compactMap { [weak self] _ in self?.type }
            .subscribe(publisher)
            .store(in: &reuseBag)
    }

    func bind(to subject: PassthroughSubject<(MediaSectionType, CGPoint), Never>) {
        adapter.offsetSubject
            .subscribe(subject)
            .store(in: &reuseBag)
    }

    func bindShowAll(to subject: PassthroughSubject<(MediaSectionType), Never>) {
        adapter.showAllTapped
            .subscribe(subject)
            .store(in: &reuseBag)
    }

    func setSectionType(_ type: MediaSectionType) {
        adapter.sectionType = type
    }

    func update(_ section: MediaListSection) {
        adapter.items.send(section.media)
    }

    private func bind() {
        adapter.didSelectItem
            .subscribe(_didSelectItem.combine)
            .store(in: &bag)

        adapter.didScrollToEnd
            .compactMap { [weak self] _ in self?.type }
            .subscribe(_didScrollToEnd.combine)
            .store(in: &bag)

        adapter.showAllTapped
            .subscribe(_showAllTapped.combine)
            .store(in: &bag)
    }

    private func setupUI() {
        self.backgroundColor = .clear
        contentView.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
