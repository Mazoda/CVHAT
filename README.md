<div align="center">

<img src="assets/images/logo.png" alt="cvhat logo" width="140" />

# cvhat

**Upload your CV. Get feedback. Land the job.**

A Flutter mobile app that helps job seekers improve their resumes through expert reviews and actionable feedback.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart SDK](https://img.shields.io/badge/Dart-%5E3.5.3-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](https://flutter.dev/multi-platform)
[![State Management](https://img.shields.io/badge/State-Provider-4FC08D)](https://pub.dev/packages/provider)
[![Style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-40C4FF.svg)](https://pub.dev/packages/flutter_lints)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)

</div>

---

## Table of Contents

- [About the Project](#about-the-project)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack & Architecture](#tech-stack--architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Available Commands](#available-commands)
- [Testing](#testing)
- [Contributing](#contributing)
- [Roadmap](#roadmap)
- [License](#license)
- [Contact & Acknowledgments](#contact--acknowledgments)

---

## About the Project

**cvhat** is a cross-platform mobile application built with Flutter that streamlines the way job seekers refine their resumes. Users can securely sign up, upload their CV as a PDF, and receive structured feedback and reviews — all from the comfort of their phone.

The app is designed for students, recent graduates, and professionals who want a fast, frictionless way to get a second opinion on their CV without juggling email threads or paid consultants. By centralizing uploads, history, and feedback into a single mobile experience, cvhat makes iterating on your resume a habit rather than a chore.

Built with a clean **provider → service → API** architecture, cvhat is also a reference project for Flutter developers looking for a real-world example of scalable state management, robust networking with Dio, and responsive UI design.

---

## Features

- 🔐 **Authentication** — Sign up, log in, OTP verification, and forgot-password flows
- 📄 **CV Upload** — Pick and upload PDF resumes via the native file picker, with an in-app PDF viewer
- 📝 **Reviews & Feedback** — Receive structured feedback on uploaded CVs and browse review history
- 🕘 **Reviews History** — Track every CV you've submitted and revisit past feedback
- ❤️ **Favorites** — Save reviews you want to revisit
- 👤 **Profile Management** — View and update your account details
- 💎 **Premium Subscriptions** — Upgrade for advanced review features
- 📶 **Offline Awareness** — Graceful handling of no-internet states via `internet_connection_checker_plus`
- 🔔 **Polished Notifications** — Toast and snackbar feedback through `toastification` and `awesome_snackbar_content`
- 📱 **Responsive UI** — Pixel-perfect across screen sizes via `flutter_screenutil` (390 × 844 design baseline)
- 🎨 **Custom Typography** — Bundled `Inter` and `PlayfairDisplay` font families
- ✨ **Smooth Animations** — Lottie animations for empty states, loading, and feedback

## Tech Stack & Architecture

### Technologies

| Category                      | Tools                                                                                                                                          |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| **Framework**                 | [Flutter](https://flutter.dev) (Dart `^3.5.3`)                                                                                                 |
| **State Management**          | [`provider`](https://pub.dev/packages/provider) (`ChangeNotifier`)                                                                             |
| **Networking**                | [`dio`](https://pub.dev/packages/dio)                                                                                                          |
| **Local Storage**             | [`shared_preferences`](https://pub.dev/packages/shared_preferences)                                                                            |
| **Responsive UI**             | [`flutter_screenutil`](https://pub.dev/packages/flutter_screenutil)                                                                            |
| **File Handling**             | [`file_picker`](https://pub.dev/packages/file_picker), [`syncfusion_flutter_pdfviewer`](https://pub.dev/packages/syncfusion_flutter_pdfviewer) |
| **Connectivity**              | [`internet_connection_checker_plus`](https://pub.dev/packages/internet_connection_checker_plus)                                                |
| **Notifications**             | [`toastification`](https://pub.dev/packages/toastification), [`awesome_snackbar_content`](https://pub.dev/packages/awesome_snackbar_content)   |
| **Animations**                | [`lottie`](https://pub.dev/packages/lottie), [`animator`](https://pub.dev/packages/animator)                                                   |
| **Localization & Formatting** | [`intl`](https://pub.dev/packages/intl)                                                                                                        |
| **Linting**                   | [`flutter_lints`](https://pub.dev/packages/flutter_lints)                                                                                      |

<details>
<summary><strong>Full dependency list</strong></summary>

See [pubspec.yaml](pubspec.yaml) for the authoritative list and pinned versions.

- `cupertino_icons: ^1.0.8`
- `flutter_screenutil: ^5.9.3`
- `provider: ^6.1.2`
- `file_picker: ^9.0.2`
- `syncfusion_flutter_pdfviewer: ^28.2.9`
- `dio: ^5.8.0+1`
- `shared_preferences: ^2.5.2`
- `awesome_snackbar_content: ^0.1.1`
- `toastification: ^3.0.2`
- `intl: ^0.19.0`
- `lottie: ^3.3.1`
- `animator: ^3.3.0`
- `internet_connection_checker_plus: ^2.7.1`

</details>

### Architecture

cvhat follows a clean **provider → service → API** layering, keeping UI, state, and networking concerns isolated and testable.

```
┌─────────────────────────────┐
│           Views             │  ← Flutter widgets / screens
│  (lib/views/...)            │
└──────────────┬──────────────┘
               │  consume / notify
┌──────────────▼──────────────┐
│          Providers          │  ← ChangeNotifiers (state)
│  (lib/providers/...)        │
└──────────────┬──────────────┘
               │  call
┌──────────────▼──────────────┐
│          Services           │  ← Singletons wrapping Dio
│  (lib/services/...)         │     return ApiResponse<T>
└──────────────┬──────────────┘
               │  HTTP
┌──────────────▼──────────────┐
│         Backend API         │
└─────────────────────────────┘
```

Key conventions:

- **Services** are singletons (`ClassName._()` + `static instance`) that wrap Dio and return a typed [`ApiResponse<T>`](lib/models/api_response.dart) with `success` / `failure` / `networkError` / `unknownError` factories.
- **Providers** are registered centrally in [lib/providers.dart](lib/providers.dart) and injected via `MultiProvider` in [lib/main.dart](lib/main.dart).
- **Navigation** is centralized in [lib/app_router.dart](lib/app_router.dart) — use `AppRouter.pushWidget` and friends instead of calling `Navigator.of(context)` directly.
- **Auth** uses bearer tokens stored locally via `LocalStorageService`.
- **Endpoints** live in [lib/constants/api_endpoints.dart](lib/constants/api_endpoints.dart).

---

## Project Structure

```
lib/
├── main.dart                  # App entry point + MultiProvider setup
├── app_router.dart            # Centralized navigation (navKey, transitions)
├── providers.dart             # Provider registration
├── constants/                 # API endpoints and app constants
├── core/
│   └── resources/             # Colors, theme, design tokens
├── data/                      # Dummy/static data
├── models/                    # Data models, including ApiResponse<T>
├── providers/                 # ChangeNotifiers (auth, reviews, profile, etc.)
├── services/                  # Singleton services (Dio, storage, connectivity)
├── utils/                     # Helpers and extensions
├── views/                     # Feature-grouped screens
│   ├── auth/                  # Login, register, OTP, forgot password
│   ├── splash_screen/
│   ├── home_screen/
│   ├── upload_cv_screen/
│   ├── reviews_history/
│   ├── feedback_screen/
│   ├── favorite_screen/
│   ├── profile_screen/
│   ├── premium_screen/
│   └── drawer/
└── widgets/                   # Reusable widgets
```

---

## Getting Started

### Prerequisites

Before you begin, make sure you have the following installed:

- [**Flutter SDK**](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.5.3`)
- [**Android Studio**](https://developer.android.com/studio) (for Android builds) **or** [**Xcode**](https://developer.apple.com/xcode/) (for iOS builds, macOS only)
- A physical device or emulator/simulator
- Git

Verify your Flutter setup:

```bash
flutter doctor
```

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/MohammedMotlaq/CVHAT.git
   cd CVHAT
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure the API base URL**

   Update the backend base URL in [lib/constants/api_endpoints.dart](lib/constants/api_endpoints.dart) to point at your environment.

4. **Run the app**

   ```bash
   flutter run
   ```

### Building for Release

```bash
# Android
flutter build apk --release
# or an app bundle for the Play Store
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

---

## Available Commands

| Command                   | Description                                                                   |
| ------------------------- | ----------------------------------------------------------------------------- |
| `flutter pub get`         | Install project dependencies                                                  |
| `flutter run`             | Run the app on a connected device or emulator                                 |
| `flutter analyze`         | Run static analysis (rules in [analysis_options.yaml](analysis_options.yaml)) |
| `flutter test`            | Run all tests                                                                 |
| `flutter build apk`       | Build a release APK                                                           |
| `flutter build appbundle` | Build an Android App Bundle                                                   |
| `flutter build ios`       | Build the iOS app (macOS only)                                                |
| `flutter clean`           | Remove build artifacts                                                        |

---

## Testing

Run the entire test suite:

```bash
flutter test
```

Run a single test by name:

```bash
flutter test test/path/to/file_test.dart --plain-name "test name"
```

---

<div align="center">

If you find **cvhat** useful, consider giving the repo a ⭐ — it helps a lot!

</div>
