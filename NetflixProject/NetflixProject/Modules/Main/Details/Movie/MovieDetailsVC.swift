//
//  MovieDetailsVC.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 8.05.26.
//

import UIKit
import Combine
import Kingfisher
import SnapKit
import Storage

protocol MovieDetailsViewModelProtocol {
    // Out
    var mediaModel: AnyPublisher<MovieDTO?, Never> { get }
    var isLiked: AnyPublisher<Bool, Never> { get }
    var isBookmarked: AnyPublisher<Bool, Never> { get }
    var isSubscribed: AnyPublisher<Bool, Never> { get }
    var canShowSubscribeButton: AnyPublisher<Bool, Never> { get }

    // In
    var backTapped: PassthroughSubject<Void, Never> { get }
    var likeTapped: PassthroughSubject<Void, Never> { get }
    var bookmarkTapped: PassthroughSubject<Void, Never> { get }
    var subscribeTapped: PassthroughSubject<Void, Never> { get }

    func onAppear()
}

final class MovieDetailsVC: UIViewController {

    private enum Const {
        static let posterHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    }

    private let titleLabel: UILabel = UILabel()
        .setTextColor(.appTextPrimary)
        .setFont(FontFamily.Roboto.bold.font(size: 24.0))
        .setNumberOfLines(0)

    private let overviewLabel = UILabel()
        .setTextColor(.appGray3)
        .setFont(FontFamily.Roboto.regular.font(size: 16.0))
        .setNumberOfLines(0)

    private let releaseDateTitleLabel: UILabel = UILabel()
        .setTextColor(.appTextPrimary)
        .setFont(FontFamily.Roboto.bold.font(size: 18.0))
        .setText(L10n.mainDetailsReleaseDate)
        .setNumberOfLines(1)

    private let releaseDateLabel: UILabel = UILabel()
        .setTextColor(.appGray3)
        .setFont(FontFamily.Roboto.regular.font(size: 16.0))
        .setNumberOfLines(1)

    private let releaseContainerStackView: UIStackView = UIStackView()
        .setAxis(.horizontal)
        .setAlignment(.center)
        .setSpacing(12)

    private let releaseDateStackView: UIStackView = UIStackView()
        .setAxis(.vertical)
        .setSpacing(4)

    private let releaseDateSpacerView = UIView()

    private lazy var posterImageView: UIImageView = UIImageView()
        .setContentMode(.scaleAspectFill)
        .setClipsToBounds(true)

    private lazy var likeButton = UIButton.iconButton(systemName: "heart")
    private lazy var bookmarkButton = UIButton.iconButton(systemName: "bookmark")
    private lazy var subscribeButton = UIButton.iconButton(systemName: "bell")

    private lazy var customNavBar: CustomNavigationBar = CustomNavigationBar()

    private lazy var rateView: RateView = RateView()

    private lazy var scrollView: UIScrollView = UIScrollView()

    private let contentView: UIView =
    UIView()
        .setBgColor(.appBg)

    private var viewModel: MovieDetailsViewModelProtocol

    private var bag: Set<AnyCancellable> = []

    init(viewModel: MovieDetailsViewModelProtocol) {
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
            .sink { [weak self] dto in
                guard let self else { return }

                titleLabel.text = dto.title
                overviewLabel.text = dto.overview
                rateView.rating = dto.voteAverage

                setPosterImage(with: dto.posterPath)

                if let releaseDate = dto.releaseDate {
                    releaseContainerStackView.isHidden = false
                    releaseDateLabel.text = releaseDate.formattedReleaseDate()
                } else {
                    releaseContainerStackView.isHidden = true
                }
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

        viewModel.isSubscribed
            .receive(on: DispatchQueue.main)
            .sink { [weak subscribeButton] isSubscribed in

                let imageName = isSubscribed ? "bell.fill" : "bell"
                subscribeButton?.setImage(
                    UIImage(systemName: imageName),
                    for: .normal
                )
            }
            .store(in: &bag)

        viewModel.canShowSubscribeButton
            .receive(on: DispatchQueue.main)
            .sink { [weak subscribeButton] canShow in
                subscribeButton?.isHidden = !canShow
            }
            .store(in: &bag)

        likeButton.tap()
            .sink { [weak self] _ in
                self?.likeButton.accessibilityValue =
                AccessibilityIdentifiers.Details.Movie.LikeButton.Value.liked
                self?.viewModel.likeTapped.send()
            }
            .store(in: &bag)

        bookmarkButton.tap()
            .sink { [weak self] _ in
                self?.bookmarkButton.accessibilityValue =
                AccessibilityIdentifiers.Details.Movie.BookmarkButton.Value.bookmarked
                self?.viewModel.bookmarkTapped.send()
            }
            .store(in: &bag)

        subscribeButton.tap()
            .sink { [weak self] _ in
                self?.subscribeButton.accessibilityValue =
                AccessibilityIdentifiers.Details.Movie.SubscribeButton.Value.subscribed
                self?.viewModel.subscribeTapped.send()
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
        contentView.addSubview(releaseContainerStackView)

        releaseDateStackView.addArrangedSubview(releaseDateTitleLabel)
        releaseDateStackView.addArrangedSubview(releaseDateLabel)

        releaseContainerStackView.addArrangedSubview(releaseDateStackView)
        releaseContainerStackView.addArrangedSubview(releaseDateSpacerView)
        releaseContainerStackView.addArrangedSubview(subscribeButton)

        releaseContainerStackView.isHidden = true
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
        releaseContainerStackView.snp.makeConstraints { make in
            make.top.equalTo(rateView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        subscribeButton.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
        overviewLabel.snp.remakeConstraints { make in
            make.top.equalTo(releaseContainerStackView.snp.bottom).offset(16)
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

extension MovieDetailsVC: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        scalePoster(with: offset)
    }

}

private extension MovieDetailsVC {

    func setupAccessibilityIdentifiers() {
        view.accessibilityIdentifier =
        AccessibilityIdentifiers.Details.Movie.screen

        titleLabel.accessibilityIdentifier =
        AccessibilityIdentifiers.Details.Movie.titleLabel

        overviewLabel.accessibilityIdentifier =
        AccessibilityIdentifiers.Details.Movie.overviewLabel

        likeButton.accessibilityIdentifier =
        AccessibilityIdentifiers.Details.Movie.LikeButton.button

        bookmarkButton.accessibilityIdentifier =
        AccessibilityIdentifiers.Details.Movie.BookmarkButton.button

        subscribeButton.accessibilityIdentifier =
        AccessibilityIdentifiers.Details.Movie.SubscribeButton.button

        likeButton.accessibilityValue =
        AccessibilityIdentifiers.Details.Movie.LikeButton.Value.notLiked
        bookmarkButton.accessibilityValue =
        AccessibilityIdentifiers.Details.Movie.BookmarkButton.Value.notBookmarked

        subscribeButton.accessibilityValue =
        AccessibilityIdentifiers.Details.Movie.SubscribeButton.Value.notSubscribed
    }

}
