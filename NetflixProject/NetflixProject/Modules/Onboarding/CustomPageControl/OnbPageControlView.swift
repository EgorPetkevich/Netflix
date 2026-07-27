//
//  OnbPageControlView.swift
//  NetflixProject
//
//  Created by George Popkich on 27.03.26.
//

import UIKit
import SnapKit

final class OnbPageControlView: UIView {

    private enum Constants {
        static let pageControlHeight: CGFloat = 13.0
    }

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.backgroundColor = .clear
        pageControl.pageIndicatorTintColor = .appDisable
        pageControl.currentPageIndicatorTintColor = .appActionRed
        return pageControl
    }()

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.delegate = self
        return sv
    }()

    private var pageViews: [UIView] = []

    var currentPage: Int {
        get { pageControl.currentPage }
        set { pageControl.currentPage = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setPages(_ pages: [UIView]) {
        pageViews.forEach { $0.removeFromSuperview() }
        pageViews = pages

        for pageView in pages {
            scrollView.addSubview(pageView)
        }

        pageControl.numberOfPages = pages.count
        currentPage = 0
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        for (index, pageView) in pageViews.enumerated() {
            pageView.frame = CGRect(
                x: CGFloat(index) * scrollView.bounds.width,
                y: 0,
                width: scrollView.bounds.width,
                height: scrollView.bounds.height
            )
        }
        scrollView.contentSize = CGSize(
            width: scrollView.bounds.width * CGFloat(pageViews.count),
            height: scrollView.bounds.height
        )
    }

    private func setupUI() {
        self.isUserInteractionEnabled = true
        addSubview(scrollView)
        addSubview(pageControl)
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(Constants.pageControlHeight + 10)
        }

        pageControl.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(Constants.pageControlHeight)
        }
    }
}

extension OnbPageControlView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.width
        guard width > 0 else { return }
        let pageIndex = round(scrollView.contentOffset.x / width)
        currentPage = Int(pageIndex)
    }
}
