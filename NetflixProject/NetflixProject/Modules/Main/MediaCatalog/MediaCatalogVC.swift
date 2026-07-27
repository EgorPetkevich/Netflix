//
//  MediaCatalogVC.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 15.04.26.
//

import UIKit
import Combine
import SnapKit
import Storage

protocol MediaCatalogViewModelProtocol {
    // Out
    var items: AnyPublisher<[any MediaDTODescription], Never> { get }

    // In
    var didSelectItem: PassthroughSubject<any MediaDTODescription, Never> { get }
    var loadNextItems: PassthroughSubject<Void, Never> { get }
    var backButtonTapped: PassthroughSubject<Void, Never> { get }
}

protocol MediaCatalogAdapterProtocol {
    var collectionView: UICollectionView { get }

    // In
    var items: CurrentValueSubject<[any MediaDTODescription], Never> { get }

    // Out
    var didSelectItem: AnyPublisher<any MediaDTODescription, Never> { get }
    var didScrollToEnd: AnyPublisher<Void, Never> { get }
}

final class MediaCatalogVC: UIViewController {

    private var collectionView: UICollectionView {
        adapter.collectionView
    }

    private let customNavBar: CustomNavigationBar = CustomNavigationBar()

    private let adapter: MediaCatalogAdapterProtocol

    private let viewModel: MediaCatalogViewModelProtocol

    private var bag: Set<AnyCancellable> = []

    init(
        navTitle: String,
        adapter: MediaCatalogAdapterProtocol,
        viewModel: MediaCatalogViewModelProtocol
    ) {
        self.adapter = adapter
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        customNavBar.title = navTitle
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
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    private func bind() {
        viewModel.items
            .sink { [weak self] items in
                self?.adapter.items.send(items)
            }
            .store(in: &bag)

        adapter.didSelectItem
            .sink { [weak self] item in
                self?.viewModel.didSelectItem.send(item)
            }
            .store(in: &bag)

        adapter.didScrollToEnd
            .sink { [weak self] _ in
                self?.viewModel.loadNextItems.send(())
            }
            .store(in: &bag)

        customNavBar.backTapped
            .sink { [weak self] in
                self?.viewModel.backButtonTapped.send(())
            }
            .store(in: &bag)
    }

    private func setupUI() {
        view.backgroundColor = .appBg
        view.addSubview(collectionView)
        view.addSubview(customNavBar)
    }

    private func setupConstraints() {
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.horizontalEdges.equalToSuperview()
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

}

extension MediaCatalogVC: UIGestureRecognizerDelegate { }
