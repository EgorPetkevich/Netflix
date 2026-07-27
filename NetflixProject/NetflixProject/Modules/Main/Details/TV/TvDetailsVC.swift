//
//  DetailsVC.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 16.04.26.
//

import UIKit
import Combine
import Kingfisher
import SnapKit
import Storage

protocol TvDetailsViewModelProtocol {
    // Out
    var mediaModel: AnyPublisher<(any MediaDTODescription)?, Never> { get }
    var isLiked: AnyPublisher<Bool, Never> { get }
    var isBookmarked: AnyPublisher<Bool, Never> { get }

    // In
    var backTapped: PassthroughSubject<Void, Never> { get }
    var likeTapped: PassthroughSubject<Void, Never> { get }
    var bookmarkTapped: PassthroughSubject<Void, Never> { get }

    func onAppear()
}

final class TvDetailsVC: UIViewController {

    private enum Const {
        static let posterHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    }

    private enum PremiumAction {
        case like
        case bookmark
    }

    private let titleLabel: UILabel = UILabel()
        .setTextColor(.appTextPrimary)
        .setFont(FontFamily.Roboto.bold.font(size: 24.0))
        .setNumberOfLines(0)

    private let overviewLabel = UILabel()
        .setTextColor(.appGray3)
        .setFont(FontFamily.Roboto.regular.font(size: 16.0))
        .setNumberOfLines(0)

    private lazy var posterImageView: UIImageView = UIImageView()
        .setContentMode(.scaleAspectFill)
        .setClipsToBounds(true)

    private lazy var likeButton = UIButton.iconButton(systemName: "heart")
    private lazy var bookmarkButton = UIButton.iconButton(systemName: "bookmark")

    private lazy var customNavBar: CustomNavigationBar = CustomNavigationBar()

    private lazy var rateView: RateView = RateView()

    private lazy var scrollView: UIScrollView = UIScrollView()

    private let contentView: UIView =
    UIView()
        .setBgColor(.appBg)

    private var viewModel: TvDetailsViewModelProtocol

    private var bag: Set<AnyCancellable> = []

    init(viewModel: TvDetailsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupAccessibilityIdentifiers()
        setupUI()
        setupConstraints()
        bind()
        startShimmer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onAppear()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    private func bind() {
        viewModel.mediaModel
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] model in
                guard let self else { return }
                titleLabel.text = model.title
                overviewLabel.text = model.overview
                rateView.rating = model.voteAverage

                setPosterImage(with: model.posterPath)
            }
            .store(in: &bag)

        viewModel.isLiked
            .receive(on: DispatchQueue.main)
            .sink { [weak likeButton] in
                likeButton?.setHeart(isLiked: $0) }
            .store(in: &bag)

        viewModel.isBookmarked
            .receive(on: DispatchQueue.main)
            .sink { [weak bookmarkButton] in
                bookmarkButton?.setBookmark(isSaved: $0) }
            .store(in: &bag)

        likeButton.tap()
            .sink { [weak self] _ in
                self?.likeButton.accessibilityValue =
                AccessibilityIdentifiers.Details.Tv.LikeButton.Value.liked
                self?.viewModel.likeTapped.send()
            }
            .store(in: &bag)

        bookmarkButton.tap()
            .sink { [weak self] _ in
                self?.bookmarkButton.accessibilityValue =
                AccessibilityIdentifiers.Details.Tv.BookmarkButton.Value.bookmarked
                self?.viewModel.bookmarkTapped.send()
            }
            .store(in: &bag)

        customNavBar.backTapped
            .sink { [weak self] _ in
                self?.viewModel.backTapped.send()
            }
            .store(in: &bag)
    }

    private func setup() {
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
    }

    private func setupUI() {
        view.addSubview(customNavBar)
        view.addSubview(scrollView)

        scrollView.addSubview(contentView)
        contentView.isUserInteractionEnabled = true

        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(rateView)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(bookmarkButton)
    }

    private func setupConstraints() {
        customNavBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(customNavBar.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.edges.horizontalEdges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.height.greaterThanOrEqualTo(scrollView.snp.height).priority(.low)
        }
        posterImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(Const.posterHeight)
        }
        bookmarkButton.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(16)
            make.right.equalToSuperview().inset(16)
            make.size.equalTo(40)
        }
        likeButton.snp.makeConstraints { make in
            make.centerY.equalTo(bookmarkButton.snp.centerY)
            make.right.equalTo(bookmarkButton.snp.left).offset(-8)
            make.height.equalTo(40)
            make.width.equalTo(30)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(bookmarkButton.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        rateView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().inset(16)
        }
        overviewLabel.snp.makeConstraints { make in
            make.top.equalTo(rateView.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func startShimmer() {
        posterImageView.layoutIfNeeded()
        posterImageView.startShimmer()
    }

    private func scalePoster(with offset: CGFloat) {
        if offset < 0 {
            let height = posterImageView.bounds.height
            let diff = abs(offset)
            let scale = 1 + diff / height

            let scaledHeight = height * scale
            let deltaY = (scaledHeight - height) / 2

            posterImageView.transform =
            CGAffineTransform(translationX: 0, y: CGFloat(-deltaY))
                .scaledBy(x: scale, y: scale)
        }
    }

    private func setPosterImage(with path: String?) {
        guard
            let path,
            let posterURL = URLBuilder.image(
                type: .poster(path: path),
                size: .original
            )
        else { return }

        KF.url(posterURL)
            .onSuccess { [weak self] _ in
                self?.posterImageView.stopShimmer()
            }
            .set(to: posterImageView)

    }

}

extension TvDetailsVC: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        scalePoster(with: offset)
    }

}

private extension TvDetailsVC {

    func setupAccessibilityIdentifiers() {
        view.accessibilityIdentifier =
        AccessibilityIdentifiers.Details.Tv.screen

        titleLabel.accessibilityIdentifier =
        AccessibilityIdentifiers.Details.Tv.titleLabel

        overviewLabel.accessibilityIdentifier =
        AccessibilityIdentifiers.Details.Tv.overviewLabel

        likeButton.accessibilityIdentifier =
        AccessibilityIdentifiers.Details.Tv.LikeButton.button

        bookmarkButton.accessibilityIdentifier =
        AccessibilityIdentifiers.Details.Tv.BookmarkButton.button

        likeButton.accessibilityValue =
        AccessibilityIdentifiers.Details.Tv.LikeButton.Value.notLiked

        bookmarkButton.accessibilityValue =
        AccessibilityIdentifiers.Details.Tv.BookmarkButton.Value.notBookmarked
    }
}
