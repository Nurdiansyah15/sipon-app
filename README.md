# Sipon (IKHLAS) Mobile App

Sipon (IKHLAS) mobile app is a Flutter-based application designed for user authentication, dashboard access, and retrieval of article, santri, and billing information from a backend API.

## Overview

This repository contains the Flutter client for the Sipon application. The app initializes a Firebase-based notification pipeline, loads environment configuration from a `.env` file, and provides a router-driven authentication flow with a dashboard experience for authenticated users.

The primary use case is a mobile interface for users to sign in, view their account and dashboard summary, and receive push notifications from the backend system. The application targets authenticated users who need access to information such as recent articles, santri profile data, and billing summaries.

## Features

- User authentication flow with login and registration screens
- Session handling with `SharedPreferences`
- Protected routing using `go_router`
- Dashboard screen that loads article, santri, and billing data
- REST API communication through a centralized `Dio` client
- Firebase Cloud Messaging integration for push notifications
- Local Android/iOS notifications via `flutter_local_notifications`
- Notification tap routing to app destinations such as dashboard or auth screens
- Indonesian locale initialization for date formatting
- Environment-based API configuration via `.env`

## Tech Stack

- Flutter project with Dart SDK constraint: `^3.9.0`
- State management: `provider`
- Routing: `go_router`
- HTTP client: `dio`
- Functional programming utilities: `fpdart`
- Environment variables: `flutter_dotenv`
- Local persistence: `shared_preferences`
- Image caching: `cached_network_image`
- Date formatting: `intl`
- Firebase: `firebase_core`, `firebase_messaging`
- Local notifications: `flutter_local_notifications`
- Backend/API layer: REST API consumed by the Flutter app
- Authentication: token-based authentication stored in preferences
- Database: not implemented in this repository; the app consumes a backend API

## Project Architecture

The repository follows a feature-based and layered structure, with a shared foundation for networking, configuration, theming, and dependency injection.

```text
lib/
├── core/
│   ├── constants/
│   ├── di/
│   ├── errors/
│   ├── network/
│   ├── services/
│   ├── state/
│   ├── theme/
│   ├── usecases/
│   └── widgets/
├── features/
│   ├── article/
│   ├── auth/
│   ├── dashboard/
│   ├── kesantrian/
│   └── keuangan/
├── shared/
│   └── router/
├── app.dart
├── firebase_options.dart
├── main.dart
├── ...
├── android/
├── ios/
├── .env
├── .env.example
├── analysis_options.yaml
├── firebase.json
├── pubspec.yaml
├── README.md
└── pubspec.lock
```

### Directory responsibilities

- `lib/core` contains shared services, constants, theme, networking, dependency wiring, and app-wide utilities.
- `lib/features` is organized by business capability, including authentication, dashboard, articles, santri data, and billing information.
- `lib/shared` contains application-level shared routing logic.
- `android/` and `ios/` contain the native platform project configuration.
- `firebase_options.dart` contains Firebase configuration for the configured platforms.
- `.env` and `.env.example` hold local environment values used by the app.

## Requirements

To run this project locally, the following tools are required:

- Flutter SDK
- Dart SDK (project constraint: `^3.9.0`)
- Android Studio
- Android emulator or a physical Android device
- Xcode for iOS builds and simulator support on macOS
- `adb` for Android device detection
- Firebase project configured for Android and iOS

This repository contains native Android and iOS project folders and Firebase configuration for those targets.

## Getting Started

Clone the repository and install dependencies:

```bash
git clone <repository-url>
cd sipon-app
flutter pub get
```

If the project uses a local environment file, create it from the example file:

```bash
cp .env.example .env
```

On Windows PowerShell, use:

```powershell
Copy-Item .env.example .env
```

## Environment Configuration

The application loads environment variables from `.env` at startup using `flutter_dotenv`.

The repository includes the following example configuration in `.env.example`:

```env
API_BASE_URL=http://10.0.2.2:8081/api/v1
```

Notes:

- `API_BASE_URL` is used by the app to connect to the backend API.
- The value may need to change depending on the device type and local backend host.
- Android emulator typically uses `http://10.0.2.2:...`.
- iOS simulator commonly uses `http://localhost:...`.
- Physical devices on the same network should use the host machine’s LAN IP.

Firebase configuration is also required. The project includes `firebase_options.dart`, and the app initializes Firebase at startup. Ensure the Firebase project matches your configured Android and iOS app registration.

## Running the Application

### Android

```bash
flutter run
```

To target a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

### iOS

On macOS, run:

```bash
flutter run
```

If multiple simulators or devices are available, use:

```bash
flutter devices
flutter run -d <device-id>
```

## Building the Application

The repository contains Android and iOS native project support. Relevant production build commands include:

```bash
flutter build apk
flutter build appbundle
flutter build ios --release
```

Use the appropriate command depending on the target platform and distribution workflow.

## Testing

This repository does not currently include a dedicated application test suite under a `test/` directory. The standard Flutter test command is still available:

```bash
flutter test
```

The project does include static analysis configuration through `analysis_options.yaml`, and the repository currently analyzes cleanly with:

```bash
flutter analyze
```

## Code Quality

The project includes Flutter linting support via `flutter_lints` and analyzer configuration in `analysis_options.yaml`.

Typical quality checks:

```bash
dart format .
flutter analyze
```

## Contributing

Contributions are welcome. To contribute:

1. Fork the repository.
2. Create a feature branch.
3. Make your changes.
4. Run formatting and static analysis checks.
5. Run tests if applicable.
6. Commit your changes.
7. Open a pull request with a clear summary of the update.

## License

No license file was found in this repository. The project does not currently declare an explicit license in the repository root.

## Additional Notes

- The app subscribes to the Firebase topic `sipon_test` during initialization.
- Notification tap handling resolves routes such as `/dashboard`, `/login`, and `/register` from message payload data.
- The repository includes Firebase support for Android and iOS, but there is no configured web target in the generated Firebase options.
- The application is intended to work with a backend API, and the API base URL is configured through `API_BASE_URL`.
