//
//  AccessibilityIdentifiers.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 1.07.26.
//

import Foundation

enum AccessibilityIdentifiers {

    enum Home {
        static let screen = "homeScreen"
        static let tableView = "homeTableView"
    }

    enum Search {
        static let screen = "searchScreen"
        static let textField = "searchTextField"
        static let resultsList = "searchResultsList"
    }

    enum Details {

        enum Movie {
            static let screen = "movieDetailsScreen"
            static let titleLabel = "movieDetailsTitleLabel"
            static let overviewLabel = "movieDetailsOverviewLabel"
            static let backButton = "movieDetailsBackButton"

            enum LikeButton {
                static let button = "movieDetailsLikeButton"

                enum Value {
                    static let liked = "liked"
                    static let notLiked = "notLiked"
                }
            }

            enum BookmarkButton {
                static let button = "movieDetailsBookmarkButton"

                enum Value {
                    static let bookmarked = "bookmarked"
                    static let notBookmarked = "notBookmarked"
                }
            }

            enum SubscribeButton {
                static let button = "movieDetailsSubscribeButton"

                enum Value {
                    static let subscribed = "subscribed"
                    static let notSubscribed = "notSubscribed"
                }
            }
        }

        enum Tv {
            static let screen = "tvDetailsScreen"
            static let titleLabel = "tvDetailsTitleLabel"
            static let overviewLabel = "tvDetailsOverviewLabel"
            static let backButton = "tvDetailsBackButton"

            enum LikeButton {
                static let button = "tvDetailsLikeButton"

                enum Value {
                    static let liked = "liked"
                    static let notLiked = "notLiked"
                }
            }

            enum BookmarkButton {
                static let button = "tvDetailsBookmarkButton"

                enum Value {
                    static let bookmarked = "bookmarked"
                    static let notBookmarked = "notBookmarked"
                }
            }
        }
    }

    enum Profile {
        static let screen = "profileScreen"
    }
}
