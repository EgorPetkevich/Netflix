//
//  MainListAdapter.swift
//  NetflixProject
//
//  Created by George Popkich on 8.04.26.
//

import UIKit
import Combine
import Storage

final class MainListAdapter: NSObject, MainListAdapterProtocol {

    private enum Const {
        static let rowHeight: CGFloat = 200
    }

    var items: CurrentValueSubject<[MediaListSection], Never> = .init([])

    var headerItem: CurrentValueSubject<(any MediaDTODescription)?, Never> = .init(nil)

    @Passthrough
    var didSelectItem: AnyPublisher<any MediaDTODescription, Never>

    @Passthrough
    var didScrollToEnd: AnyPublisher<MediaSectionType, Never>

    @Passthrough
    var headerDetailsTapped: AnyPublisher<any MediaDTODescription, Never>

    @Passthrough
    var showAllTapped: AnyPublisher<MediaSectionType, Never>

    @Passthrough
    private var collectionOffsetSubject: AnyPublisher<(MediaSectionType, CGPoint), Never>

    private var sectionOffsets: [MediaSectionType: CGPoint] = [:]

    private let headerView = HeroHeaderView()

    private var headerHeight: CGFloat {
        UIScreen.main.bounds.height * 0.7
    }

    var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 40.0
        tableView.contentInset.top = 40
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()

    private var bag: Set<AnyCancellable> = []

    override init() {
        super.init()
        setupTable()
        setupHeader()
        bind()
    }

    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(MediaCollectionRow.self)

        tableView.rowHeight = UITableView.automaticDimension

        tableView.contentInsetAdjustmentBehavior = .never
    }

    private func setupHeader() {
        headerView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.tableView.bounds.width,
            height: self.headerHeight
        )

        tableView.tableHeaderView = headerView
    }

    private func bind() {
        items
            .scan(
                (old: [MediaListSection](), new: [MediaListSection]())
            ) { acc, new in
                (old: acc.new, new: new)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pair in
                guard let self else { return }
                self.handleSectionsUpdate(old: pair.old, new: pair.new)
            }
            .store(in: &bag)

        collectionOffsetSubject
            .sink { [weak self] type, offset in
                self?.sectionOffsets[type] = offset
            }
            .store(in: &bag)

        headerItem
            .sink { [headerView] model in
                guard let model else { return }
                headerView.configure(with: model)
            }
            .store(in: &bag)

        headerView.headerDetailsTapped
            .compactMap { [weak self] _ in
                self?.headerItem.value
            }
            .subscribe(_headerDetailsTapped.combine)
            .store(in: &bag)
    }

    private func handleSectionsUpdate(
        old: [MediaListSection],
        new: [MediaListSection]
    ) {
        guard old.count == new.count else {
            tableView.reloadData()
            return
        }

        for sectionIndex in 0..<new.count {
            let oldSection = old[sectionIndex]
            let newSection = new[sectionIndex]

            guard oldSection.media.count != newSection.media.count else { continue }

            updateSection(at: sectionIndex, with: newSection)
        }
    }

    private func updateSection(
        at index: Int,
        with section: MediaListSection
    ) {
        let indexPath = IndexPath(row: 0, section: index)

        guard
            let cell = tableView.cellForRow(at: indexPath) as? MediaCollectionRow
        else { return }

        cell.update(section)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return Const.rowHeight
    }
}

extension MainListAdapter: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return items.value.count
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 1
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let section = items.value[indexPath.section]
        let cell: MediaCollectionRow = tableView.dequeue(at: indexPath)
        let offset = sectionOffsets[section.type] ?? CGPoint(x: -10.0, y: 0.0)
        cell.setup(section, offset: offset)

        cell.bind(to: _didSelectItem.combine)
        cell.bind(to: _didScrollToEnd.combine)
        cell.bind(to: _collectionOffsetSubject.combine)
        cell.bindShowAll(to: _showAllTapped.combine)

        return cell
    }

}

extension MainListAdapter: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let headerView = SectionHeaderView()
        let title = items.value[section].title.uppercased()
        let type = items.value[section].type
        headerView.configure(with: title, type: type)
        headerView.bind(to: _showAllTapped.combine)

        return headerView
    }

}

extension MainListAdapter: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        headerView.update(offset: offset)
    }

}
