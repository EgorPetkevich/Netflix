//
//  HomeVC.swift
//  NetflixProject
//
//  Created by George Popkich on 8.04.26.
//

import UIKit
import SnapKit
import Combine
import Storage

protocol HomeViewModelProtocol {
    // Out
    var sections: AnyPublisher<[MediaListSection], Never> { get }
    var headerModel: AnyPublisher<(any MediaDTODescription)?, Never> { get }
    // In
    var didSelectItem: PassthroughSubject<any MediaDTODescription, Never> { get }
    var loadNextItems: PassthroughSubject<MediaSectionType, Never> { get }
    var headerDetailsTapped: PassthroughSubject<any MediaDTODescription, Never> { get }
    var showAllTapped: PassthroughSubject<MediaSectionType, Never> { get }
}

protocol MainListAdapterProtocol {
    var tableView: UITableView { get }

    // In
    var items: CurrentValueSubject<[MediaListSection], Never> { get }
    var headerItem: CurrentValueSubject<(any MediaDTODescription)?, Never> { get }

    // Out
    var didSelectItem: AnyPublisher<any MediaDTODescription, Never> { get }
    var didScrollToEnd: AnyPublisher<MediaSectionType, Never> { get }
    var headerDetailsTapped: AnyPublisher<any MediaDTODescription, Never> { get }
    var showAllTapped: AnyPublisher<MediaSectionType, Never> { get }
}

final class HomeVC: UIViewController {

    private var tableView: UITableView {
        return adapter.tableView
    }

    private let adapter: MainListAdapterProtocol

    private let viewModel: HomeViewModelProtocol

    private var bag: Set<AnyCancellable> = []

    init(viewModel: HomeViewModelProtocol, adapter: MainListAdapterProtocol) {
        self.viewModel = viewModel
        self.adapter = adapter
        super.init(nibName: nil, bundle: nil)
        setupTabBar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private func bind() {
        viewModel.sections
            .subscribe(adapter.items)
            .store(in: &bag)

        viewModel.headerModel
            .subscribe(adapter.headerItem)
            .store(in: &bag)

        adapter.didSelectItem
            .subscribe(viewModel.didSelectItem)
            .store(in: &bag)

        adapter.didScrollToEnd
            .subscribe(viewModel.loadNextItems)
            .store(in: &bag)

        adapter.headerDetailsTapped
            .subscribe(viewModel.headerDetailsTapped)
            .store(in: &bag)

        adapter.showAllTapped
            .subscribe(viewModel.showAllTapped)
            .store(in: &bag)
    }

    private func setupTabBar() {
        self.tabBarItem = UITabBarItem(
            title: "Home",
            image: .init(systemName: "house"),
            tag: .zero
        )
    }

    private func setupUI() {
        view.backgroundColor = .appBg
        view.accessibilityIdentifier = AccessibilityIdentifiers.Home.screen
        tableView.accessibilityIdentifier = AccessibilityIdentifiers.Home.tableView
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
