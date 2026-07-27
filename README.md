# Netflix-iOS

Netflix-iOS is a Netflix-inspired iOS application for browsing movies, TV shows, and people from The Movie Database (TMDB). The app includes authentication, personalized media lists, local persistence, Firebase backup, notifications, StoreKit purchases, and a mix of UIKit and SwiftUI screens.

> This is an educational/demo project and is not affiliated with Netflix.

## Features

- Onboarding, splash screen, authentication, and passcode-protected app entry
- Email/password, Google, and guest sign-in through Firebase Authentication
- Home catalog with TMDB movie and TV sections
- Movie, TV, and person detail screens
- Search with media-type filtering
- Favorites, bookmarks, and release waiting lists
- Local media persistence through the `Storage` target
- Firebase backup/restore for user media data
- Local notifications for saved release dates
- StoreKit paywall and purchase restoration flow
- Profile screen with media counters, theme selection, support email, and app review entry points
- Localized resources for English, Russian, Spanish, French, and German

## Tech Stack

- Swift 5
- UIKit and SwiftUI
- The Composable Architecture
- Combine and RxSwift/RxCocoa
- SnapKit
- SwiftData
- Firebase Auth, Core, Firestore, Realtime Database, and Storage
- Google Sign-In
- StoreKit
- Kingfisher
- Lottie
- SwiftGen
- SwiftLint
- XCTest and XCUITest
- Fastlane

## Requirements

- macOS with Xcode 26.2 or newer recommended
- iOS 17.0 or newer for the app target
- iPhone simulator or device
- Ruby and Bundler for Fastlane commands
- SwiftGen if regenerating typed resources
- SwiftLint if running lint locally
- A configured Firebase project
- A TMDB API bearer token stored in Firestore

## Project Structure

```text
.
|-- NetflixProject/
|   |-- NetflixProject.xcodeproj
|   |-- NetflixProject/          # App target
|   |-- Storage/                 # Local media storage target
|   |-- NetflixProjectTests/     # Unit tests
|   |-- NetflixProjectUITests/   # UI tests
|   |-- fastlane/                # Local test and CI lanes
|   `-- Gemfile
|-- swiftgen.yml
|-- .swiftlint.yml
`-- README.md
```

## Architecture

The app uses coordinators for high-level navigation and a lightweight custom dependency container for service registration and resolution. Feature implementation is mixed:

- UIKit screens are used for flows such as onboarding, authentication, home, media catalog, and details.
- SwiftUI with The Composable Architecture is used for feature state management in modules such as search, favorites, bookmarks, notifications, profile, and paywall.
- `Storage` contains DTOs, SwiftData/Core Data-style model objects, and storage services for movies, TV shows, people, and combined media lists.
- Network requests are routed through service abstractions around TMDB endpoints.
- Firebase services handle authentication, token fetching, and backup/restore.

## Setup

1. Clone the repository.

   ```sh
   git clone <repository-url>
   cd Netflix
   ```

2. Open the project in Xcode.

   ```sh
   open NetflixProject/NetflixProject.xcodeproj
   ```

3. Resolve Swift Package Manager dependencies in Xcode.

4. Configure signing.

   The project currently uses the `egorpetkevich.NetflixProject` bundle identifier and a specific development team. Change the bundle identifier and team in Xcode if you are building with another Apple Developer account.

5. Configure Firebase.

   The app expects `GoogleService-Info.plist` at:

   ```text
   NetflixProject/NetflixProject/App/GoogleService-Info.plist
   ```

   Firebase should provide Authentication, Firestore, and Realtime Database access for the app.

6. Configure the TMDB bearer token.

   `FetchTokenService` loads the TMDB API token from Firestore after a Firebase user is authenticated. Create this Firestore document:

   ```text
   Collection: Moviedb
   Document: Bearer
   Field: token = <TMDB bearer token>
   ```

   The token is cached in Keychain after the first successful fetch.

7. Run the app.

   Select the `NetflixProject` scheme and run it on an iPhone simulator or device.

## Resource Generation

SwiftGen generates strongly typed accessors for localized strings and fonts. After changing localizations or fonts, run this command from the repository root:

```sh
swiftgen config run --config swiftgen.yml
```

Generated files:

- `NetflixProject/NetflixProject/Resources/Localizations/Generated/Strings.swift`
- `NetflixProject/NetflixProject/Resources/Fonts/Generated/Fonts.swift`

## Testing

Run tests from Xcode with the `NetflixProject` scheme, or use `xcodebuild` from the repository root:

```sh
xcodebuild test \
  -project NetflixProject/NetflixProject.xcodeproj \
  -scheme NetflixProject \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Fastlane is also configured:

```sh
cd NetflixProject
bundle install
bundle exec fastlane test
bundle exec fastlane ci
```

Available lanes:

- `test` runs local tests with `scan`
- `ci` runs tests and then creates a clean Debug build

## Linting

Run SwiftLint from the repository root:

```sh
swiftlint
```

The local configuration lives in `.swiftlint.yml`.

## UI Testing

UI tests use launch arguments defined in `AppLaunchArguments` to open app states directly. `BaseUITestCase` always launches the app with the UI-testing argument and individual tests can add module-specific launch arguments for details screens or the main flow.

## Notes

- The app uses TMDB data and images through `api.themoviedb.org` and `image.tmdb.org`.
- The splash overlay is hidden after home content finishes loading.
- User media is restored from Firebase backup on app start and synchronized in the background.
- StoreKit uses `NetflixProject/NetflixProject/Services/Store/Configuration.storekit` for local purchase testing.
